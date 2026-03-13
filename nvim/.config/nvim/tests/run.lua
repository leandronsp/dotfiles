#!/usr/bin/env nvim -l
-- ===================================================================
-- Test Runner Script
-- ===================================================================
-- Runs all tests in the lua/tests/ directory using Plenary
-- Usage: nvim -l tests/run.lua

local plenary_path = vim.fn.stdpath('data') .. '/lazy/plenary.nvim'

-- Add plenary to runtime path
vim.opt.rtp:append(plenary_path)

-- Set up test environment
require('plenary.busted')

-- Test configuration
local test_config = {
  -- Test directories to search
  test_dirs = {
    'lua/tests',
  },
  
  -- Test file pattern  
  test_pattern = '_spec.lua',
  
  -- Output format
  output_format = 'utfTerminal',  -- or 'TAP', 'json'
}

-- Helper function to find test files
local function find_test_files()
  local test_files = {}
  
  for _, dir in ipairs(test_config.test_dirs) do
    local dir_path = vim.fn.getcwd() .. '/' .. dir
    
    if vim.fn.isdirectory(dir_path) == 1 then
      -- Use recursive globpath to find test files in subdirectories
      local files = vim.fn.globpath(dir_path, '**/*' .. test_config.test_pattern, false, true)
      for _, file in ipairs(files) do
        table.insert(test_files, file)
      end
    end
  end
  
  return test_files
end

-- Main test runner function
local function run_tests()
  print('🧪 Running Neovim Configuration Tests...\n')
  
  -- Load the main configuration first
  print('📦 Loading configuration...')
  require('config')
  print('✅ Configuration loaded successfully\n')
  
  -- Find all test files
  local test_files = find_test_files()
  
  if #test_files == 0 then
    print('❌ No test files found!')
    return 1
  end
  
  print('📋 Found ' .. #test_files .. ' test files:')
  for _, file in ipairs(test_files) do
    print('  • ' .. vim.fn.fnamemodify(file, ':t'))
  end
  print()
  
  -- Run tests using PlenaryBustedDirectory
  local test_results = {}
  local total_passed = 0
  local total_failed = 0
  
  for _, test_file in ipairs(test_files) do
    local file_name = vim.fn.fnamemodify(test_file, ':t:r')
    print('🏃 Running ' .. file_name .. '...')
    
    -- Load and run the test file
    local ok, result = pcall(dofile, test_file)
    
    if ok then
      print('  ✅ ' .. file_name .. ' completed')
      total_passed = total_passed + 1
    else
      print('  ❌ ' .. file_name .. ' failed: ' .. tostring(result))
      total_failed = total_failed + 1
    end
  end
  
  -- Print summary
  print('\n📊 Test Summary:')
  print('  ✅ Passed: ' .. total_passed)
  print('  ❌ Failed: ' .. total_failed)
  print('  📁 Total: ' .. #test_files)
  
  if total_failed == 0 then
    print('\n🎉 All tests passed!')
    return 0
  else
    print('\n💥 Some tests failed!')
    return 1
  end
end

-- Run the tests and exit with appropriate code
local exit_code = run_tests()
if exit_code == 0 then
  vim.cmd('qall!')
else
  vim.cmd('cquit!')
end