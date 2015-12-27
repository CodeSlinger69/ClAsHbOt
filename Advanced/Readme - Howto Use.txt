How to prepare an adjusted texts.csv file
1. Use root explorer in android to find the Clash of Clans apk file in /data/app
2. Tap the apx, choose View, navigate to assets/csv, long press texts.csv and choose Extract
3. Use hex editor to insert 4 0x00 bytes at offset 9 in the file, save the modified file
4. Extract archive.  ()Rename to texts.7z and use 7Zip, for example.)
5. Rename extracted file to texts.csv and open in text editor.
6. Search for "Tap or press and hold to deploy troops" and replace with "".  
7. Search for "Battle starts in:" and replace with "".
8. Save file.

Using the modified texts.csv file.
1. Use root explorer to move the modified texts.csv file to /data/data/com.supercell.clashofclans/update/csv
2. Force stop then restart Clash.


