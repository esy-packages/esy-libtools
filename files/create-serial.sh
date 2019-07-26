echo Version 2.4.6
echo 2.4.6 > .serial

echo 'Reset date on .serial'
touch -t 200905010101 .serial

echo '.serial: ${cat .serial}'

