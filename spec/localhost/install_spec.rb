require 'spec_helper'

describe user('rdp_local') do
  it { should exist }
end

describe user('rdp_local') do
  it { should belong_to_group 'Administrators' }
end

describe user('rdp_local') do
  it { should belong_to_group 'Remote Desktop Users' }
end

describe file('C:/tools/screen-resolution') do
  it { should be_directory }
end

describe file("C:/tools/screen-resolution/RDP-to-#{ACCOUNT}-at-res1366x768.cmd") do
  it { should be_file }
end

describe file('C:/Users/rdp_local/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup') do
  it { should be_directory }
end

describe file("C:/Users/rdp_local/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/RDP-to-#{ACCOUNT}-at-res1366x768.lnk") do
  it { should be_file }
end

describe windows_registry_key('HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server') do
  it { should exist }
end

describe windows_registry_key('HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server') do
  it { should have_property_value('fDenyTSConnections', :type_qword, '0') }
end

describe windows_registry_key('HKLM\SOFTWARE\Microsoft\Terminal Server Client') do
  it { should exist }
end

describe windows_registry_key('HKLM\SOFTWARE\Microsoft\Terminal Server Client') do
  it { should have_property_value('AuthenticationLevelOverride', :type_qword, '0') }
end
