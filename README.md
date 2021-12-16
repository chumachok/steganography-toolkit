the toolkit supports least significant bit (lsb) steganography with .png and .bmp images

## embedding
when --embed flag is present, the application expects the following flags:
* -m, --medium <path to the cover medium>
* -d, --data <path to the secret image>
* -o, --output <output filename of the medium with embedded secret image>
* -p, --password <password used to encrypt the secret image>
* -c, --cipher <cipher to use, optional, defaults to Triple DES>

the mediums with embedded secret images are written to the output/encrypted directory.

```
ruby main.rb -m fixtures/cover_medium.bmp -d fixtures/secret.png -o message.bmp -p secret --embed
```

## extraction
when --extract flag is present, the application expects the following flags:
* -m, --medium <path to the cover medium with embedded image>
* -p, --password <password used to decrypt the secret image>
* -c, --cipher <cipher to use, optional, defaults to Triple DES>

the extracted secret images are written to the output/decrypted directory.
```
ruby main.rb -m output/encrypted/message.bmp -p secret --extract
```

