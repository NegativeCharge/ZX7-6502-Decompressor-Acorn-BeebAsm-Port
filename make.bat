cd .\tests\
for %%x in (*.tsc) do del "%%x" 
for %%x in (*.bin) do ..\tools\zx7.exe "%%x" "%%~nx.bin.zx7"

cd ..
cmd /c "BeebAsm.exe -v -i zx7_test.s.asm -do zx7_test.ssd -opt 3"