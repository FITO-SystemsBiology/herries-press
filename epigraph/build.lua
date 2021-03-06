
--[=========================[--
   L3BUILD FILE FOR EPIGRAPH
--]=========================]--

module  = "epigraph"
version = "1.5e"
pkgdate = "2020/01/02"
gittag  = module.."-v"..version

uploadconfig = {
  version     = version,
  author      = "Peter R Wilson; Will Robertson",
  license     = "lppl1.3c",
  summary     = "Mark vertical rules in margin of text",
  ctanPath    = "/macros/latex/contrib/epigraph",
  repository  = "https://github.com/wspr/herries-press/",
  bugtracker  = "https://github.com/wspr/herries-press/issues",
  description = [[
Epigraphs are the pithy quotations often found at the start (or end) of a chapter. Both single epigraphs and lists of epigraphs are catered for. Various aspects are easily configurable.
  ]]
}

announce = {}
announce["1.5e"] = [[
  Try to prevent breaks after epigraphs, and add \epigraphnoindent to automatically suppress indentation after all \epigraph commands.
]]
uploadconfig.announcement = announce[version]

tagfiles     = {"*.dtx"}

--[=================[--
     CUSTOMISATION
--]=================]--

today = os.date("%Y/%m/%d")
if pkgdate ~= today then
  print("Package date is not today:"..
        "\nPkg date: "..pkgdate..
        "\nToday:    "..today)
end

require("l3build-wspr.lua")

--[===========[--
     TAGGING
--]===========]--

status_bool = false

function check_status()
  if status_bool then
    return true
  end

  local handle = io.popen('git status --porcelain --untracked-files=no')
  local gitstatus = string.gsub(handle:read("*a"),'%s*$','')
  handle:close()
  if gitstatus=="" then
    print("Checking git status: clean")
    status_bool = true
    return status_bool
  else
    print("ABORTING, git status is not clean:")
    print(gitstatus)
    status_bool = false
    return status_bool
  end
end

function tag_hook(tagname)
  if check_status() then
    os.execute('git commit -a -m "Step release tag"')
    os.execute('git tag -a -m "" ' .. gittag)
  end
end


function update_tag(file,content,tagname,tagdate)
  if content==nil then
    print("content should not be nil!")
  end

  if not(check_status()) then
    return content
  end

  if string.match(file, "%.sty$") then
    local findpattern = "%d%d%d%d/%d%d/%d%d%sv%d.%d%S%s"
    local foundtag = content:match(findpattern)
    print("Old package date/version: " .. foundtag)
    local newtag = pkgdate .. " v" .. version .. " "
    print("Replaced with:            " .. newtag)
    local newcontent = content:gsub(findpattern,newtag)
    return newcontent
  end
  return content
end
