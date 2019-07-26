echo '.serial before:'
cat .serial || true

echo Version 2.4.6
echo 2.4.6 > .serial

touch -t 200905010101 .serial

echo '.serial:'
cat .serial
