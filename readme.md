1. Install [Git](https://git-scm.com/downloads) and Delphi (any version starting from D2007, recommended version is 10.3.3 Rio)

1. [Clone](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository) this repository into any place in your disk:

    `git clone https://github.com/sasgis/sas.requires`

1. Open Delphi IDE Options and create Environment variable with name SAS and set its value with full path to the sas.requires folder. 

    ![](/.screenshots/EditUserVariable.png)

1. Set the `Library path` (navigate to the end of the path, add path separator `;` and then add one of this lines):

    - for Delphi XE4 and newer:
    `$(SAS)\alcinoe-code\source;$(SAS)\graphics32\Source;$(SAS)\toolbar2000\Source;$(SAS)\tbx\Source;$(SAS)\tbx\Source\Themes;$(SAS)\embeddedwb\source;$(SAS)\pascalscript\Source;$(SAS)\vsagps\Runtime;$(SAS)\vsagps\Public;$(SAS)\ccr-exif;$(SAS)\synedit\Source;$(SAS)\mormot;$(SAS)\mormot\SQLite3`

    - for Delphi 2007 to XE3:
    `$(SAS)\alcinoe\source;$(SAS)\graphics32\Source;$(SAS)\toolbar2000\Source;$(SAS)\tbx\Source;$(SAS)\tbx\Source\Themes;$(SAS)\embeddedwb\source;$(SAS)\pascalscript\Source;$(SAS)\vsagps\Runtime;$(SAS)\vsagps\Public;$(SAS)\ccr-exif;$(SAS)\synedit\Source;$(SAS)\mormot;$(SAS)\mormot\SQLite3`

    *The only difference here is path to the Alcinoe component (`alcinoe-code` for XE4 and newer and `alcinoe` for D2007-XE3).*

    Depending on the version of Delphi the `Library path` can be found in:

    - `Tools - Options - Language - Delphi Options - Library` - for Delphi 10.3 (don't forget to set platform:  `Windows 32-bit`)
    - `Tools - Options - Library Win32` - for Delphi 2007
    
        ![](/.screenshots/LibraryDirectories.png)

1. Install 3 design-time packages: Graphics32, Toolbar2000 and TBX.

    - for Graphics32 open GR32.groupproj file, select and Build GR32_R\*.bpl, select and Install GR32_D\*.bpl

        - Delphi 10.3: `graphics32\Source\Packages\RX3\GR32.groupproj` (Build GR32_RRX3.bpl, Install GR32_DRX3.bpl)
        - Delphi XE2: `graphics32\Source\Packages\XE2\GR32.groupproj` (Build GR32_RXE2.bpl, Install GR32_DXE2.bpl)
        - Delphi 2007: `graphics32\Source\Packages\2007\GR32.groupproj` (Build GR32_R2007.bpl, Install GR32_D2007.bpl)

            ![](/.screenshots/GR32.png)

    - for Toolbar2000: 
        - open and Build `Toolbar2000\Packages\TB2000_Run.dpk`
        - open and Install `Toolbar2000\Packages\TB2000_Dsgn.dpk`

            ![](/.screenshots/TB2K_Build.png)

    - for TBX: 
        - open and Build `TBX\Packages\TBX_Run.dpk`
        - open and Install `TBX\Packages\TBX_Dsgn.dpk`