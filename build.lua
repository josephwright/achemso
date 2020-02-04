#!/usr/bin/env texlua

-- Identify the bundle and module
bundle = ""
module = "achemso"

-- There are a few more file types to install
installfiles = {"*.cfg", "*.cls", "*.sty"}

-- Typeset the demo as well as source
typesetfiles = {"*.dtx", "*.tex"}

-- Only typeset the user part of the .dtx
-- To avoid an issue with the .tex file, a bit of TeX coding
typsetcmds = [[
  \\ifdefined\\OnlyDescription\\AtBeginDocument{\\OnlyDescription}\\fi
]]

-- Detail how to set the version automatically
function update_tag(file,content,tagname,tagdate)
  local format = "%d%d%d%d%-%d%d%-%d%d v%d%.%d+%w?"
  -- The presence of natmove means we have to be a bit careful
  for _,term in pairs({"Submission","Support","achemso"}) do
    content = string.gsub(content,
       format .. " " .. term,
       tagdate .. " " .. tagname ..  " " .. term)
  end
  return string.gsub(content,
    "achemso " .. format,
    "achemso " .. tagdate .. " " .. tagname) 
end

-- Release a TDS-style zip
packtdszip  = true

-- No tests for this bundle
testfildir = ""

-- Find and run the build system
kpse.set_program_name ("kpsewhich")
if not release_date then
  dofile(kpse.lookup("l3build.lua"))
end

