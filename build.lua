#!/usr/bin/env texlua

-- Identify the bundle and module
bundle = ""
module = "achemso"

-- There are a few more file types to install
installfiles = {"*.cfg", "*.cls", "*.sty"}

-- Typeset the demo as well as source
typesetfiles = {"*.dtx", "*.tex"}

-- All-in-one .dtx file
unpackfiles  = {"*.dtx"}

-- Only typeet the user part of the .dtx
-- To avoid an issue with the .tex file, a bit of TeX coding
typsetcmds = [[
  \\ifdefined\\OnlyDescription\\AtBeginDocument{\\OnlyDescription}\\fi
]]

-- Release a TDS-style zip
packtdszip  = true

-- No tests for this bundle
testfildir = ""

-- Find and run the build system
kpse.set_program_name ("kpsewhich")
dofile (kpse.lookup ("l3build.lua"))
