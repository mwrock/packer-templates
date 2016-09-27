batch 'restore sxs health' do
  code 'Dism.exe /online /Cleanup-Image /RestoreHealth'
end

batch 'clean SxS' do
  code 'Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase'
end
