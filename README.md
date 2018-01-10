# hxoracle - Oracle connector for Haxe CPP

THIS IS AN EXPERIMENTAL HAXE LIB

USE AT YOUR OWN RISK

#### Configure Haxelib
1. Clone this repository
2. Set 'haxelib dev hxoracle YOUR_HXORACLE_PATH'

#### Configure OCI
1. Get OCI from Oracle website:
    - Windows: http://www.oracle.com/technetwork/topics/winsoft-085727.html
    - Linux: http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

    You need to download:
    - Instant Client Package - Basic v. 12.2.0.1.0
    - Instant Client Package - SDK v. 12.2.0.1.0

2. Create the following folder structure inside your clonned folder:

```
oci
  |
  - linux
  |   |
  |   - include (put all linux .h files)
  |   - so (put all .so files)
  |
  - windows
      |
      - dll (put all .dll AND .sym files)
      - include (put all windows .h files)
      - lib
          |
          - msvc (put all .lib files from msvc folder * NOT bc folder)
```

