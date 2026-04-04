local Process = require("@lune/process")
local Fs = require("@lune/fs")
local Stdio = require("@lune/stdio")
local Regex = require("@lune/regex")
local Serde = require("@lune/serde")
local Net = require("@lune/net")
local CliBuilder = require("../luau_packages/cli_builder")

local CLI = CliBuilder.cli
local option = CliBuilder.option
local command = CliBuilder.command
local argument = CliBuilder.argument

type GitDependency = {
	repo: string,
	rev: string,
	path: string?,
}

type RegistryDependency = {
	name: string,
	version: string,
}

type WallyDependency = {
	wally: string,
	version: string,
}

type WorkspaceDependecny = {
	workspace: string,
	version: string,
}

type Dependency = GitDependency | RegistryDependency | WallyDependency | WorkspaceDependecny

type PesdeManifest = {
	name: string,
	private: boolean?,
	scripts: { [string]: string },
	target: {
		environment: string,
	},
	version: string,
	dev_dependencies: { [string]: Dependency }?,
	dependencies: { [string]: Dependency }?,
}

local function isFilePesdeManifest(filePath: string)
	local isFile = Fs.isFile(filePath)
	if not isFile then
		return false
	end

	return Regex.new("pesde.toml"):isMatch(filePath)
end

local function isDependencyGit(dep: Dependency)
	return typeof(dep["repo"]) == "string"
end

local function printError(message: string)
	Stdio.write(Stdio.color("red"))
	Stdio.write(Stdio.style("bold"))
	print(message)
	Stdio.write(Stdio.style("reset"))
	Stdio.write(Stdio.color("reset"))
end

local function checkAllVersionsAreTheSame(manifest: PesdeManifest)
	local versions: { string } = {}

	if manifest.dependencies then
		for _, v in manifest.dependencies do
			if not isDependencyGit(v) then
				continue
			end
			table.insert(versions, (v :: GitDependency).rev)
		end
	end

	if manifest.dev_dependencies then
		for _, v in manifest.dev_dependencies do
			if not isDependencyGit(v) then
				continue
			end
			table.insert(versions, (v :: GitDependency).rev)
		end
	end

	local version = versions[1]
	for _, v in versions do
		if v ~= version then
			print("Version mismatch! Versions found:")
			for _, ver in versions do
				print("- " .. ver)
			end
			return false
		end
	end
	return true, version
end

local function doesPackageExist(name: string, rev: string)
	local respone = Net.request({
		method = "GET",
		url = `https://api.github.com/repos/its-a-bit-random/sapling/contents/packages?ref={rev}`,
	})
	if not respone.ok then
		printError(`Failed to request github and verify package exists: ({respone.statusCode}) {respone.statusMessage}`)
		print("Will add anyway, make sure to run pesde install to see if it can install")
		return true
	else
		local cool = Serde.decode("json", respone.body) :: {
			{
				name: string,
			}
		}

		for _, v in cool do
			if v.name == name then
				return true
			end
		end

		return false
	end
end

CLI.new()
	:setName("SaplingCLI")
	:addAuthor("Sebastian2852 <gramps@itsabitrandom.com>")
	:addOption(
		option
			.new()
			:setName("project-path")
			:addAlias("p")
			:setDefaultValue("./pesde.toml")
			:setType("PATH")
			:setDescription("Path to the pesde.toml manifest file")
			:build()
	)
	:addCommand(command
		.new()
		:setName("check")
		:setDescription("Check that all sapling packages have matching versions")
		:setCallback(function(context)
			local pesdePath = context.globalOptions["project-path"] :: string
			if not isFilePesdeManifest(pesdePath) then
				printError("Path doesn't point to pesde manifest file")
				Process.exit(1)
			end
			local pesdeManieftData = Serde.decode("toml", Fs.readFile(pesdePath)) :: PesdeManifest
			local isValid = checkAllVersionsAreTheSame(pesdeManieftData)
			if not isValid then
				Process.exit(1)
			end
		end)
		:build())
	:addCommand(command
		.new()
		:setName("add")
		:setDescription("Add a new package")
		:addArgument(
			argument.new():setName("name"):setDescription("Name of the package"):setRequired(true):setType("string")
		)
		:setCallback(function(context)
			local pesdePath = context.globalOptions["project-path"] :: string
			local packageName = context.commandArguments["name"] :: string

			if not isFilePesdeManifest(pesdePath) then
				printError("Path doesn't point to pesde manifest file")
				Process.exit(1)
			end
			local pesdeManieftData = Serde.decode("toml", Fs.readFile(pesdePath)) :: PesdeManifest
			local valid, rev = checkAllVersionsAreTheSame(pesdeManieftData)
			if not valid then
				Process.exit(1)
			end

			if not doesPackageExist(packageName, rev) then
				printError(`No package with then name "{packageName}" exists on rev "{rev}"`)
				Process.exit(1)
			end

			local deps = pesdeManieftData.dependencies or {}
			deps[(string.upper(string.sub(packageName, 1, 1)) .. string.sub(packageName, 2, -1))] = {
				repo = "its-a-bit-random/sapling",
				rev = rev,
				path = `packages/{packageName}`,
			}
			pesdeManieftData.dependencies = deps
			local newData = Serde.encode("toml", pesdeManieftData)
			Fs.writeFile(pesdePath, newData)
		end)
		:build())
	:run(Process.args)
