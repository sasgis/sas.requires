1. Install [Git](https://git-scm.com/downloads) and Delphi 10.4.2 Sydney

1. [Clone](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository) this repository into any place in your disk:

    `git clone https://github.com/sasgis/sas.requires`

1. Open Delphi IDE Options and create Environment variable with name SAS and set its value with full path to the sas.requires folder. 

    ![](/.screenshots/EditUserVariable.png)

1. Set the `Library path` (navigate to the end of the path, add path separator `;` and add the following line):

    `$(SAS)\alcinoe-code\source;$(SAS)\ccr-exif;$(SAS)\clipper2\Delphi\Clipper2Lib;$(SAS)\embeddedwb\source;$(SAS)\graphics32\Source;$(SAS)\mormot2\src;$(SAS)\mormot2\src\app;$(SAS)\mormot2\src\core;$(SAS)\mormot2\src\crypt;$(SAS)\mormot2\src\db;$(SAS)\mormot2\src\lib;$(SAS)\mormot2\src\misc;$(SAS)\mormot2\src\net;$(SAS)\mormot2\src\orm;$(SAS)\mormot2\src\rest;$(SAS)\mormot2\src\script;$(SAS)\mormot2\src\soa;$(SAS)\mormot2\src\tools;$(SAS)\mormot2\src\ui;$(SAS)\pascalscript\Source;$(SAS)\synedit\Source;$(SAS)\tbx\Source;$(SAS)\tbx\Source\Themes;$(SAS)\toolbar2000\Source;$(SAS)\virtualtreeview\Source;$(SAS)\vsagps\Public;$(SAS)\vsagps\Runtime`
    
    `Library path` can be found in:

    - `Tools - Options - Language - Delphi - Library` (don't forget to set platform:  `Windows 32-bit`)
    
        ![](/.screenshots/LibraryDirectories.png)

1. Install 3 design-time packages: Graphics32, Toolbar2000 and TBX.

    - for Graphics32 open GR32.groupproj file (or the corresponding GR32_R.dproj and GR32_D.dproj), select and Build GR32_R\*.bpl, select and Install GR32_D\*.bpl

        - Delphi 10.4: `graphics32\Source\Packages\D104\GR32.groupproj` (Build GR32_RD104.bpl, Install GR32_DD104.bpl)
        
            ![](/.screenshots/GR32.png)

    - for Toolbar2000: 
        - open and Build `Toolbar2000\Packages\TB2000_Run.dpk`
        - open and Install `Toolbar2000\Packages\TB2000_Dsgn.dpk`

            ![](/.screenshots/TB2K_Build.png)

    - for TBX: 
        - open and Build `TBX\Packages\TBX_Run.dpk`
        - open and Install `TBX\Packages\TBX_Dsgn.dpk`