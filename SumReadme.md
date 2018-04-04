NAME
  sum (Supermicro Update Manager)

SYNOPSIS
  sum [OPTIONs] [COMMAND] [COMMAND ARGUMENTS]

OPTIONS
  -h  Shows help information.
  -v  Displays the verbose output.
  -i  <BMC/CMM IP address or BMC/CMM host name>
  -l  <BMC/CMM system list file name. Refer to the user's guide for formatting>
  -u  <BMC/CMM user ID>
  -p  <BMC/CMM user password>
  -c  <command name> (case insensitive)

USAGE MODES
○  Single System Out-Of-Band (OOB) Management [operates on single BMC/CMM]:
    Must use -i,-u, -p options
○  Single System In-Band Management [operates on local OS]: Do not use -i, -u
    and -p options
○  Concurrent Systems OOB Management [operates on multiple system BMCs/CMMs]:
    Replace -i option with -l option

COMMANDS
Function Group             Command Names

Key Management             ActivateProductKey, QueryProductKey, ClearProductKey
System Checks              CheckOOBSupport, CheckAssetInfo,
                           CheckSystemUtilization, CheckSensorData
BIOS Management            GetBIOSInfo, UpdateBios, GetDefaultBiosCfg,
                           GetCurrentBiosCfg, ChangeBiosCfg,
                           LoadDefaultBiosCfg, GetDmiInfo, ChangeDmiInfo,
                           EditDmiInfo, SetBiosAction
BMC Management             GetBmcInfo, UpdateBmc, GetBmcCfg, ChangeBmcCfg
System Event Log           GetEventLog, ClearEventLog
CMM Management             GetCmmInfo, UpdateCmm, GetCmmCfg, ChangeCmmCfg
Storage Management         GetRaidControllerInfo, UpdateRaidController,
                           GetRaidCfg, ChangeRaidCfg, GetSataInfo, GetNvmeInfo
Applications               TpmProvision, MountIsoImage, UnmountIsoImage

COMMAND USAGE
  See help message for each command
  Syntax:"  # ./sum -h -c <command name>"
  Notes: 1)Command support is platform dependent. Please refer to Appendix C in
         the user's guide for platform dependency hints.
         2)If BMC/CMM user ID or password includes special characters, it has
         to be quoted.

EXAMPLES
OOB
  # ./sum -i 192.168.34.56 -u ADMIN -p ADMIN -c ChangeBmcCfg --file BmcCfg.txt
  # ./sum -i 192.168.34.56 -u ADMIN -p "&123456" -c ChangeBmcCfg --file
  BmcCfg.txt
Multiple systems OOB
  # ./sum -l IP_ADDR_RANGE.txt -u ADMIN -p ADMIN -c GetBIOSInfo --file BIOS.rom
  # ./sum -l IP_ADDR_RANGE.txt -u ADMIN -p "&123456" -c GetBIOSInfo --file
  BIOS.rom
In-Band
  # ./sum -c UpdateBios --file BIOS.rom
Help Message
  # ./sum -h -c UpdateBios
