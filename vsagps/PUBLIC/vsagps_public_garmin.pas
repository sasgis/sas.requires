(*
  VSAGPS Library. Copyright (C) 2011, Sergey Vasketsov
  Please read <info_*.txt> file for License details and conditions (GNU GPLv3)
*)
unit vsagps_public_garmin;
(*
*)

{$I vsagps_defines.inc}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  SysUtils,
  vsagps_public_base,
  vsagps_public_types;

const
  semicircles_to_gradus_koeff = DWORD(2 shl 30);

  // layers for garmin usb
  PT_Protocol_Layer = 0;
  PT_Application_Layer = 20;

  // Unknown Pvt layer
  PT_Unknown200_Layer = 200; // (Packet_Type=200, Packet_ID=30664, Data_Size=84)
  PT_Unknown72_Layer = 72;


  Pid_Data_Available = 2;
  Pid_Start_Session = 5;
  Pid_Session_Started = 6;

  Pid_Unknown30664_Pvt=30664; // (Packet_Type=200, Packet_ID=30664, Data_Size=84)
  Pid_Unknown34760_Pvt=34760; // (Packet_Type=200, Packet_ID=34760, Data_Size=84)
  Pid_Unknown34888_Pvt=34888; // (Packet_Type=72, Packet_ID=34888, Data_Size=64)
  Pid_Unknown35016_Pvt=35016; // (Packet_Type=200, Packet_ID=35016, Data_Size=64)
  Pid_Unknown35144_Pvt=35144; // (Packet_Type=200, Packet_ID=35144, Data_Size=64)
  Pid_Unknown35400_Pvt=35400;
  Pid_Unknown47048_Pvt=47048; // (Packet_Type=200, Packet_ID=47048, Data_Size=64)


  MAX_BUFFER_SIZE = 4096;
  ASYNC_DATA_SIZE = 64;

(*
3.2.3.1 Data Available Packet
The Data Available packet signifies that data has become available for the host to read. The host should read data until
receiving a transfer with no data (zero length). No data is associated with this packet.
Direction =  Device to Host
Packet ID =  Pid_Data_Available
Packet Data Type = n/a

3.2.3.2 Start Session Packet
The Start Session packet must be sent by the host to begin transferring packets over USB. It must also be sent anytime
the host deliberately stops transferring packets continuously over USB and wishes to begin again. No data is associated
with this packet.
Direction =  Host to Device
Packet ID =  Pid_Start_Session
Packet Data Type = n/a

3.2.3.3 Session Started Packet
The Session Started packet indicates that transfers can take place to and from the device. The host should ignore any
packets it receives before receiving this packet. The data returned with this packet is the device’s unit ID.
Direction =  Device to Host
Packet ID =  Pid_Session_Started
Packet Data Type = uint32
*)

(*
3.2.4 Garmin USB Driver for Microsoft Windows
This section provides information related to the use of the Garmin-provided USB driver for use on Microsoft Windows
operating systems. This driver is compatible with Windows 98, ME, 2000 and XP. It is assumed that the reader is
familiar with programming for the Windows Platform Software Development Kit and Driver Development Kit.
Applications send packets to the device using the Win32 WriteFile function. If the packet size is an exact multiple of
the USB packet size, an additional call to WriteFile should be made passing in no data.
Applications receive packets asynchronously from the device by constantly calling the Win32 DeviceIoControl
function. When an application receives a Data Available packet, it should read packets using the Win32 ReadFile
function. Once an application begins receiving packets for a protocol using DeviceIoControl or ReadFile, all
subsequent packets for that protocol will be received using the same function.
*)


(*
3.2.4.3 ReadFile, WriteFile Functions
The buffer passed in by the client to ReadFile or WriteFile must be no larger than MAX_BUFFER_SIZE. If data
exceeds MAX_BUFFER_SIZE, multiple calls must be made.

3.2.4.4 IOCTLS
The following constants are intended for use with the DeviceIoControl function. For each IOCTL below, the return
value is the number of bytes written to the output buffer.
*)

  // Output buffer receives 4-byte API version.
  // IOCTL_API_VERSION = CTL_CODE( FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS )
  IOCTL_API_VERSION = $00222000; // out buffer size = 4, no in buffer

  // Output buffer receives asynchronous data from the device. Size is equal to or less than ASYNC_DATA_SIZE. The
  // client should constantly have a call into the driver with this IOCTL. The driver stores a limited amount of
  // asynchronous data.
  // IOCTL_ASYNC_IN = CTL_CODE (FILE_DEVICE_UNKNOWN, 0x850, METHOD_BUFFERED, FILE_ANY_ACCESS)
  IOCTL_ASYNC_IN = $00222140; // out buffer size = 0x40, no in buffer

  // Output buffer receives 4-byte USB packet size. Client is responsible for sending a zero length transfer if the amount of
  // data sent to the device is an integral multiple of the USB packet size.
  // IOCTL_USB_PACKET_SIZE = CTL_CODE (FILE_DEVICE_UNKNOWN, 0x851, METHOD_BUFFERED, FILE_ANY_ACCESS)
  IOCTL_USB_PACKET_SIZE = $00222144; // out buffer size = 4, no in buffer

(* 4.1.1 Basic Packet IDs *)
  Pid_Protocol_Array = 253; // may not be implemented in all devices
  Pid_Product_Rqst = 254;
  Pid_Product_Data = 255;
  Pid_Ext_Product_Data = 248; // may not be implemented in all devices



(* 4.2 L001 – Link Protocol 1
This Link protocol is used for the majority of devices (see section 8.2 on page 60). This protocol is the same as L000
– Basic Link Protocol, except that the following Packet IDs are used in addition to the Basic Packet IDs: *)
  L001_Pid_Etx_Byte = 3; // UNDOCUMENTED IN L001
  L001_Pid_Ack_Byte = 6; // UNDOCUMENTED IN L001
  L001_Pid_Command_Data = 10;
  L001_Pid_Xfer_Cmplt = 12;
  L001_Pid_Unknown_13 = 13; // UNDOCUMENTED
  L001_Pid_Date_Time_Data = 14;
  L001_Pid_Dle_Byte = 16; // UNDOCUMENTED IN L001
  L001_Pid_Position_Data = 17;
  L001_Pid_Prx_Wpt_Data = 19;
  L001_Pid_Nack_Byte = 21; // UNDOCUMENTED IN L001
  L001_Pid_PseudoRange = 22; // UNDOCUMENTED - 0x16  DataSize=21  ? (one per satellite) * - pseudorange and perhaps doppler info  // TPseudoRangeData
  L001_Pid_Position_Error = 23; // UNDOCUMENTED - 0x17  DataSize=52  Position error and more * // TPositionErrorData
  L001_Pid_Satellite_Status = 26;  // UNDOCUMENTED - 0x1A  DataSize=96  Satellite status * // TSatelliteStatusData
  L001_Pid_Records = 27;
  L001_Pid_EnableAsyncEvents = 28; // UNDOCUMENTED - 0x1C
  L001_Pid_Rte_Hdr = 29;
  L001_Pid_Rte_Wpt_Data = 30;
  L001_Pid_Almanac_Data = 31;
  L001_Pid_Trk_Data = 34;
  L001_Pid_Wpt_Data = 35;
  L001_Pid_Unknown_38 = 38; // UNDOCUMENTED 0x26  DataSize=4 (unit_id?)
  L001_Pid_Unknown_39 = 39; // UNDOCUMENTED 0x27  DataSize=2
  L001_Pid_Unknown_40 = 40; // UNDOCUMENTED 0x28  DataSize=4
  L001_Pid_Pvt_Data = 51;
  L001_Pid_RMR_Data = 52; // UNDOCUMENTED
  L001_Pid_Ephemeris_Data = 53; // UNDOCUMENTED - transmitting Ephemeris
  LOO1_Pid_50HzCounter = 54; // = 0x36 - Datasize=9 bytes - UNDOCUMENTED - a 50Hz counter and some obscure data (for each tracked satellite) // T50HzCounterData
  // 55 = 0x37 - UNDOCUMENTED
  L001_Pid_1KHzCounter = 56; // 0x38 - UNDOCUMENTED - Datasize=37 (one per sat) - T1KHzCounterData  - Pseudorange, integrated phase, signal strength, Time of week, 1KHz counter and 511500Hz counter (Half of the bit rate of the C/A code )
  L001_Pid_Capacity_Data = 95; // UNDOCUMENTED
  L001_Pid_Rte_Link_Data = 98;
  L001_Pid_Trk_Hdr = 99;
  L001_Pid_Tx_Unlock_Key = 108; // UNDOCUMENTED
  L001_Pid_Ack_Unlock_key = 109; // UNDOCUMENTED
  L001_Pid_RecMeasData = 114;
  L001_Pid_FlightBook_Record = 134;
  L001_Pid_Lap = 149;
  L001_Pid_Wpt_Cat = 152;
  L001_Pid_Req_Icon_Id = 881; // UNDOCUMENTED 0x371
  L001_Pid_Ack_Icon_Id = 882; // UNDOCUMENTED 0x372
  L001_Pid_Ack_Icon_Data = 884; // UNDOCUMENTED 0x374
  L001_Pid_Icon_Data = 885; // UNDOCUMENTED 0x375
  L001_Pid_Req_Clr_Tbl = 886; // UNDOCUMENTED 0x376
  L001_Pid_Ack_Clr_Tbl = 887; // UNDOCUMENTED 0x377
  L001_Pid_Run = 990;
  L001_Pid_Workout = 991;
  L001_Pid_Workout_Occurrence = 992;
  L001_Pid_Fitness_User_Profile = 993;
  L001_Pid_Workout_Limits = 994;
  L001_Pid_Course = 1061;
  L001_Pid_Course_Lap = 1062;
  L001_Pid_Course_Point = 1063;
  L001_Pid_Course_Trk_Hdr = 1064;
  L001_Pid_Course_Trk_Data = 1065;
  L001_Pid_Course_Limits = 1066;

(* 4.3 L002 – Link Protocol 2
This Link protocol is used mainly for panel-mounted aviation devices (see section 8.2 on page 60). This protocol is the same as L000
 – Basic Link Protocol, except that the following Packet IDs are used in addition to the Basic Packet IDs: *)
  L002_Pid_Almanac_Data = 4;
  L002_Pid_Command_Data = 11;
  L002_Pid_Xfer_Cmplt = 12;
  L002_Pid_Date_Time_Data = 20;
  L002_Pid_Position_Data = 24;
  L002_Pid_Prx_Wpt_Data = 27;
  L002_Pid_Records = 35;
  L002_Pid_Rte_Hdr = 37;
  L002_Pid_Rte_Wpt_Data = 39;
  L002_Pid_Wpt_Data = 43;

(* 6.2.3 Tag Values for Protocol_Data_Type *)
  Tag_Phys_Prot_Id = 'P'; // tag for Physical protocol ID
  Tag_Link_Prot_Id = 'L'; // tag for Link protocol ID
  Tag_Appl_Prot_Id = 'A'; // tag for Application protocol ID
  Tag_Data_Type_Id = 'D'; // tag for Data Type ID


(* A010 – Device Command Protocol 1
This protocol is implemented by the majority of devices (see section 8.2 on page 60).
Note: The “Cmnd_Turn_Off_Pwr” command may not be acknowledged by the device.
Note: The PC can send Cmnd_Abort_Transfer in the middle of a transfer of data to the device in order to cancel the transfer.
The enumerated values for Command_Id_Type are shown below:
*)
const
  A010_Cmnd_Abort_Transfer = 0; // abort current transfer
  A010_Cmnd_Transfer_Alm = 1; // transfer almanac
  A010_Cmnd_Transfer_Posn = 2; // transfer position
  A010_Cmnd_Transfer_Prx = 3; // transfer proximity waypoints
  A010_Cmnd_Transfer_Rte = 4; // transfer routes
  A010_Cmnd_Transfer_Time = 5; // transfer time
  A010_Cmnd_Transfer_Trk = 6; // transfer track log
  A010_Cmnd_Transfer_Wpt = 7; // transfer waypoints
  A010_Cmnd_Turn_Off_Pwr = 8; // turn off power
  A010_Cmnd_Undocumented_14 = 14; // UNDOCUMENTED - get unit_id?
  A010_Cmnd_Transfer_Voltage = 17; // UNDOCUMENTED - get voltage
  A010_Cmnd_Start_Pvt_Data = 49; // start transmitting PVT data
  A010_Cmnd_Stop_Pvt_Data = 50; // stop transmitting PVT data
  A010_Cmnd_Transfer_Capacity = 63; // UNDOCUMENTED - transfer memory information
  A010_Cmnd_FlightBook_Transfer = 92; // transfer flight records
  A010_Cmnd_Transfer_Ephemeris = 93; // UNDOCUMENTED - transfer Ephemeris
  A010_Cmnd_Start_RMR = 110; // start transmitting Receiver Measurement Records
  A010_Cmnd_Stop_RMR = 111; // start transmitting Receiver Measurement Records
  A010_Cmnd_Transfer_Laps = 117; // transfer fitness laps
  A010_Cmnd_Transfer_Wpt_Cats = 121; // transfer waypoint categories
  A010_Cmnd_Transfer_Runs = 450; // transfer fitness runs
  A010_Cmnd_Transfer_Workouts = 451; // transfer workouts
  A010_Cmnd_Transfer_Workout_Occurrences = 452; // transfer workout occurrences
  A010_Cmnd_Transfer_Fitness_User_Profile = 453; // transfer fitness user profile
  A010_Cmnd_Transfer_Workout_Limits = 454; // transfer workout limits
  A010_Cmnd_Transfer_Courses = 561; // transfer fitness courses
  A010_Cmnd_Transfer_Course_Laps = 562; // transfer fitness course laps
  A010_Cmnd_Transfer_Course_Points = 563; // transfer fitness course points
  A010_Cmnd_Transfer_Course_Tracks = 564; // transfer fitness course tracks
  A010_Cmnd_Transfer_Course_Limits = 565; // transfer fitness course limits

(*
6.3.2 A011 – Device Command Protocol 2
This protocol is implemented mainly by panel-mounted aviation devices (see section 8.2 on page 60). The
enumerated values for Command_Id_Type are shown below:
*)
  A011_Cmnd_Abort_Transfer = 0; // abort current transfer
  A011_Cmnd_Transfer_Alm = 4; // transfer almanac
  A011_Cmnd_Transfer_Rte = 8; // transfer routes
  A011_Cmnd_Transfer_Prx = 17; // transfer proximity waypoints
  A011_Cmnd_Transfer_Time = 20; // transfer time
  A011_Cmnd_Transfer_Wpt = 21; // transfer waypoints
  A011_Cmnd_Turn_Off_Pwr = 26; // turn off power


type
  Product_Data_Type=record
    product_ID: Word;
    software_version: SmallInt;
    product_description: AnsiChar; // ... zero or more additional null-terminated strings
  end;
  PProduct_Data_Type=^Product_Data_Type;

  Ext_Product_Data_Type=record
    product_description: AnsiChar; // ... zero or more additional null-terminated strings
  end;
  PExt_Product_Data_Type=^Ext_Product_Data_Type;

  Protocol_Data_Type=packed record
    tag: Byte;
    data: Word;
  end;
  PProtocol_Data_Type=^Protocol_Data_Type;

  Protocol_Array_Type=packed array[0..1] of Protocol_Data_Type;
  PProtocol_Array_Type=^Protocol_Array_Type;
(*
The Protocol_Array_Type is an array of Protocol_Data_Type structures. The number of Protocol_Data_Type
structures contained in the array is determined by observing the size of the received packet data.
typedef Protocol_Data_Type Protocol_Array_Type[];
*)

(*
5.4 Standard Beginning and Ending Packets
Many Application protocols use standard beginning and ending packets called Pid_Records and Pid_Xfer_Cmplt, respectively
The Records_Type contains a 16-bit integer that indicates the number of data packets to follow, excluding the Pid_Xfer_Cmplt packet
*)
  Records_Type = packed record
    RecCount: Word; //uint16;
  end;
  PRecords_Type = ^Records_Type;

(* 7.3.12 position_type
The position_type is used to indicate latitude and longitude in semicircles, where 231 semicircles equal 180 degrees.
North latitudes and East longitudes are indicated with positive numbers; South latitudes and West longitudes are
indicated with negative numbers. *)
  position_type = packed record
    lat: sint32; // latitude in semicircles
    lon: sint32; // longitude in semicircles
  end;

  D700_Position_Type = packed record
    p: radian_position_type;
  end;
  PD700_Position_Type = ^D700_Position_Type;

(* 7.4.23 D301_Trk_Point_Type
The “time” member indicates the time at which the track log point was recorded.
The ‘alt’ and ‘dpth’ members may or may not be supported on a given device. A value of 1.0e25 in either of these
fields indicates that this parameter is not supported or is unknown for this track point.
When true, the “new_trk” member indicates that the track log point marks the beginning of a new track log segment.
temp - Temperature. May not be supported by all devices. A value of 1.0e25 in this field indicates that this parameter is
not supported or is unknown for this track point.
*)
  D300_Trk_Point_Type = packed record
    posn: position_type; // position
    time: time_type; // time
    new_trk: Byte; // bool; // new track segment?
  end;
  PD300_Trk_Point_Type=^D300_Trk_Point_Type;

  D301_Trk_Point_Type = packed record
    posn: position_type; // position
    time: time_type; // time
    alt: float32; // altitude in meters
    dpth: float32; // depth in meters
    new_trk: Byte; // bool; // new track segment?
    end;
  PD301_Trk_Point_Type=^D301_Trk_Point_Type;

  D302_Trk_Point_Type = packed record
    posn: position_type; // position
    time: time_type; // time
    alt: float32; // altitude in meters
    dpth: float32; // depth in meters
    temp: float32; // temp in degrees C
    new_trk: Byte; // bool; // new track segment?
  end;
  PD302_Trk_Point_Type=^D302_Trk_Point_Type;
  
(* 7.4.25 D303_Trk_Point_Type
All fields are defined the same as D301_Trk_Point_Type except as noted below.
The “posn” member is invalid if both lat and lon are equal to 0x7FFFFFFF.
The “heart_rate” member is invalid if its value is equal to 0.
Two consecutive track points with invalid position, invalid altitude, and invalid heart rate indicate a pause in track
point recording during the time between the two points. *)
  D303_Trk_Point_Type = packed record
    posn: position_type; // position
    time: time_type; // time
    alt: float32; // altitude in meters
    heart_rate: uint8; // heart rate in beats per minute
  end;
  PD303_Trk_Point_Type = ^D303_Trk_Point_Type;

(* 7.4.26 D304_Trk_Point_Type
All fields are defined the same as D303_Track_Point_Type except as noted below.
The “distance” member is the cumulative distance traveled in the track up to this point in meters as determined by the wheel sensor or from the position, whichever is more accurate.
If the distance cannot be obtained, the “distance” member has a value of 1.0e25, indicating that it is invalid.
A value of 0xFF for the “cadence” member indicates that it is invalid.
Two consecutive track points with invalid position, invalid altitude, invalid heart rate, invalid distance and invalid
cadence indicate a pause in track point recording during the time between the two points. *)
  D304_Trk_Point_Type = packed record
    posn: position_type; // position
    time: time_type; // time
    alt: float32; // altitude in meters
    distance: float32; // distance traveled in meters. See below.
    heart_rate: uint8; // heart rate in beats per minute
    cadence: uint8; // in revolutions per minute
    sensor: Byte; // bool; // is a wheel sensor present?
  end;
  PD304_Trk_Point_Type = ^D304_Trk_Point_Type;

(* 7.4.27 D310_Trk_Hdr_Type
The ‘trk_ident’ member has a maximum length of 51 characters including the terminating NULL. *)
  D310_Trk_Hdr_Type=packed record
    dspl: Byte; // bool; // display on the map?
    color: uint8; // color (same as D108)
    trk_ident: AnsiChar; // null-terminated ansistring
  end;
  PD310_Trk_Hdr_Type=^D310_Trk_Hdr_Type;

(* 7.4.28 D311_Trk_Hdr_Type *)
  D311_Trk_Hdr_Type = packed record
    index: uint16; // unique among all tracks received from device
  end;
  PD311_Trk_Hdr_Type = ^D311_Trk_Hdr_Type;

(* 7.4.29 D312_Trk_Hdr_Type
The 'trk_ident' member has a maximum length of 51 characters including the terminating NULL.
The “color” member can be one of the following values: D110_clr_* constants + clr_DefaultColor = 255 *)
  D312_Trk_Hdr_Type = packed record
    dspl: Byte; // bool; // display on the map?
    color: uint8; // color (see below)
    trk_ident: AnsiChar; // ansichar trk_ident[] // null-terminated ansistring
  end;
  PD312_Trk_Hdr_Type = ^D312_Trk_Hdr_Type;

(* 7.3.15 symbol_type
The symbol_type is used in certain devices to indicate the symbol for a waypoint
The enumerated values for symbol_type are shown below. Note that most devices that use this type are limited to a
much smaller subset of these symbols, and no attempt is made in this document to indicate which subsets are valid for
each of these devices. However, the device will ignore any disallowed symbol values that are received and instead
substitute the value for a generic dot symbol. Therefore, there is no harm in attempting to use any value shown in the
table below except that the device may not accept the requested value. *)
  symbol_type = uint16;


(* 6.4 A100 – Waypoint Transfer Protocol
When the host commands the device to send waypoints, the device will send every waypoint stored in its database.
When the host sends waypoints to the device, the host may selectively transfer any waypoint it chooses.
7.4.1 D100_Wpt_Type
7.4.2 D101_Wpt_Type
The enumerated values for the “smbl” member of the D101_Wpt_Type are the same as those for symbol_type (see section 7.3.15 on page 26).
However, since the “smbl” member of the D101_Wpt_Type is only 8-bits (instead of 16-bits), all symbol_type values whose upper byte
is non-zero are disallowed in the D101_Wpt_Type. The “dst” member is valid only during the Proximity Waypoint Transfer Protocol.
7.4.3 D102_Wpt_Type
7.4.4 D103_Wpt_Type
7.4.5 D104_Wpt_Type
7.4.6 D105_Wpt_Type
7.4.7 D106_Wpt_Type
7.4.8 D107_Wpt_Type
7.4.9 D108_Wpt_Type
The enumerated values for the “dspl” member of the D108_Wpt_Type are the same as the “dspl” member of the D103_Wpt_Type.
The “attr” member should be set to a value of 0x60.
The “subclass” member of the D108_Wpt_Type is used for map waypoints only, and should be set to 0x0000 0x00000000 0xFFFFFFFF 0xFFFFFFFF 0xFFFFFFFF for other classes of waypoints.
The “alt” and “dpth” members may or may not be supported on a given device. A value of 1.0e25 in either of these fields indicates that this parameter is not supported or is unknown for this waypoint.
The “dist” member is used during the Proximity Waypoint Transfer Protocol only, and should be set to 1.0e25 for other cases.
The “comment” member of the D108_Wpt_Type is used for user waypoints only, and should be an empty string for other waypoint classes.
The “facility” and “city” members are used only for aviation waypoints, and should be empty strings for other waypoint classes.
The “addr” member is only valid for MAP_ADRS_WPT class waypoints and will be an empty string otherwise.
The “cross_road” member is valid only for MAP_INT_WPT class waypoints, and will be an empty string otherwise.
7.4.10 D109_Wpt_Type
All fields are defined the same as D108_Wpt_Type except as noted below.
dtyp - Data packet type, must be 0x01 for D109_Wpt_Type.
dspl_color - The 'dspl_color' member contains three fields; bits 0-4 specify the color, bits 5-6 specify the waypoint
display attribute and bit 7 is unused and must be 0. Color values are as specified for D108_Wpt_Type except that the default value is 0x1f. Display attribute values are as specified for D108_Wpt_Type.
attr - Attribute. Must be 0x70 for D109_Wpt_Type.
ete - Estimated time en route in seconds to next waypoint. Default value is 0xFFFFFFFF.
7.4.11 D110_Wpt_Type
*)

  D100_Wpt_Type = packed record
    ident: packed array [0..5] of AnsiChar; // identifier
    posn: position_type; // position
    unused: uint32; // should be set to zero
    cmnt: packed array [0..39] of AnsiChar; // comment
  end;
  PD100_Wpt_Type=^D100_Wpt_Type;

  D101_Wpt_Type = packed record
    ident: packed array [0..5] of AnsiChar; // identifier
    posn: position_type; // position
    unused: uint32; // should be set to zero
    cmnt: packed array [0..39] of AnsiChar; // comment
    dst: float32; // proximity distance (meters)
    smbl: uint8; // symbol id
  end;
  PD101_Wpt_Type=^D101_Wpt_Type;

  D102_Wpt_Type=packed record
    ident: packed array [0..5] of AnsiChar; // identifier
    posn: position_type; // position
    unused: uint32; // should be set to zero
    cmnt: packed array [0..39] of AnsiChar; // comment
    dst: float32; // proximity distance (meters)
    smbl: symbol_type; // symbol id
  end;
  PD102_Wpt_Type=^D102_Wpt_Type;

  D103_Wpt_Type = packed record
    ident: packed array [0..5] of AnsiChar; // identifier
    posn: position_type; // position
    unused: uint32; // should be set to zero
    cmnt: packed array [0..39] of AnsiChar; // comment
    smbl: uint8; // symbol id
    dspl: uint8; // display option
  end;
  PD103_Wpt_Type=^D103_Wpt_Type;

  D104_Wpt_Type = packed record
    ident: packed array [0..5] of AnsiChar; // identifier
    posn: position_type; // position
    unused: uint32; // should be set to zero
    cmnt: packed array [0..39] of AnsiChar; // comment
    dst: float32; // proximity distance (meters)
    smbl: symbol_type; // symbol id
    dspl: uint8; // display option
  end;
  PD104_Wpt_Type=^D104_Wpt_Type;

  D105_Wpt_Type = packed record
    posn: position_type; // position
    smbl: symbol_type; // symbol id
    wpt_ident: AnsiChar; // null-terminated string
  end;
  PD105_Wpt_Type=^D105_Wpt_Type;

  D106_Wpt_Type = packed record
    wpt_class: uint8; // class
    subclass: packed array [0..12] of uint8; // subclass
    posn: position_type; // position
    smbl: symbol_type; // symbol id
    wpt_ident: AnsiChar; // null-terminated string
    lnk_ident: AnsiChar; // null-terminated string
  end;
  PD106_Wpt_Type=^D106_Wpt_Type;
(* The enumerated values for the “wpt_class” member of the D106_Wpt_Type are as follows:
Zero: indicates a user waypoint (“subclass” is ignored).
Non-zero: indicates a non-user waypoint (“subclass” must be valid). *)

  D107_Wpt_Type = packed record
    ident: packed array [0..5] of AnsiChar; // identifier
    posn: position_type; // position
    unused: uint32; // should be set to zero
    cmnt: packed array [0..39] of AnsiChar; // comment
    smbl: uint8; // symbol id
    dspl: uint8; // display option
    dst: float32; // proximity distance (meters)
    color: uint8; // waypoint color
  end;
  PD107_Wpt_Type=^D107_Wpt_Type;
(* The enumerated values for the “smbl”/“dspl” member of the D107_Wpt_Type are the same as the “smbl”/“dspl” member of the D103_Wpt_Type (respectively). *)

  D108_Wpt_Type = packed record
    wpt_class: uint8; // class (see below)
    color: uint8; // color (see below)
    dspl: uint8; // display options (see below)
    attr: uint8; // attributes (see below)
    smbl: symbol_type; // waypoint symbol
    subclass: packed array [0..17] of uint8; // subclass
    posn: position_type; // position
    alt: float32; // altitude in meters
    dpth: float32; // depth in meters
    dst: float32; // proximity distance in meters
    state: packed array [0..1] of AnsiChar; // state
    cc: packed array [0..1] of AnsiChar; // country code
    ident: AnsiChar; // variable length string
    comment: AnsiChar; // waypoint user comment
    facility: AnsiChar; // facility name
    city: AnsiChar; // city name
    addr: AnsiChar; // address number
    cross_road: AnsiChar; // intersecting road label
  end;
  PD108_Wpt_Type=^D108_Wpt_Type;

  D109_Wpt_Type = packed record
    dtyp: uint8; // data packet type (0x01 for D109)
    wpt_class: uint8; // class
    dspl_color: uint8; // display & color (see below)
    attr: uint8; // attributes (0x70 for D109)
    smbl: symbol_type; // waypoint symbol
    subclass: packed array [0..17] of uint8; // subclass
    posn: position_type; // position
    alt: float32; // altitude in meters
    dpth: float32; // depth in meters
    dst: float32; // proximity distance in meters
    state: packed array [0..1] of AnsiChar; // state
    cc: packed array [0..1] of AnsiChar; // country code
    ete: uint32; // outbound link ete in seconds
    ident: AnsiChar; // variable length string
    comment: AnsiChar; // waypoint user comment
    facility: AnsiChar; // facility name
    city: AnsiChar; // city name
    addr: AnsiChar; // address number
    cross_road: AnsiChar; // intersecting road label
  end;
  PD109_Wpt_Type=^D109_Wpt_Type;

  D110_Wpt_Type = packed record
    dtyp: uint8; // data packet type (0x01 for D110)
    wpt_class: uint8; // class
    dspl_color: uint8; // display & color (see below)
    attr: uint8; // attributes (0x80 for D110)
    smbl: symbol_type; // waypoint symbol
    subclass: packed array [0..17] of uint8; // subclass
    posn: position_type; // position
    alt: float32; // altitude in meters
    dpth: float32; // depth in meters
    dst: float32; // proximity distance in meters
    state: packed array [0..1] of AnsiChar; // state
    cc: packed array [0..1] of AnsiChar; // country code
    ete: uint32; // outbound link ete in seconds
    temp: float32; // temperature */
    time: time_type; // timestamp */
    wpt_cat: uint16; // category membership */
    // null-terminated strings:
    ident: AnsiChar; // variable length string
    comment: AnsiChar; // waypoint user comment
    facility: AnsiChar; // facility name
    city: AnsiChar; // city name
    addr: AnsiChar; // address number
    cross_road: AnsiChar; // intersecting road label
  end;
  PD110_Wpt_Type=^D110_Wpt_Type;
(* All fields are defined the same as D109_Wpt_Type except as noted below.
wpt_cat - Waypoint Category. May not be supported by all devices. Default value is 0x0000. This is a bit field that provides category membership information for the waypoint.
The waypoint may be a member of up to 16 categories. If a bit is set then the waypoint is a member of the corresponding category.
For example, if bits 0 and 4 are set then the waypoint is a member of categories 1 and 5. For more information see section 6.5 on page 13.
temp - Temperature. May not be supported by all devices. A value of 1.0e25 in this field indicates that this parameter is not supported or is unknown for this waypoint.
time - Time. May not be supported by all devices. A value of 0xFFFFFFFF in this field indicates that this parameter is not supported or is unknown for this waypoint.
attr - Attribute. Must be 0x80 for D110_Wpt_Type.
posn - Position. If a D110 waypoint is received that contains a value in the lat field of the posn field that is greater than
2^30 or less than -2^30, then that waypoint shall be rejected.
*)

const
(* The enumerated values for the “smbl” member of the D103_Wpt_Type: *)
  D103_smbl_dot = 0; // dot symbol
  D103_smbl_house = 1; // house symbol
  D103_smbl_gas = 2; // gas symbol
  D103_smbl_car = 3; // car symbol
  D103_smbl_fish = 4; // fish symbol
  D103_smbl_boat = 5; // boat symbol
  D103_smbl_anchor = 6; // anchor symbol
  D103_smbl_wreck = 7; // wreck symbol
  D103_smbl_exit = 8; // exit symbol
  D103_smbl_skull = 9; // skull symbol
  D103_smbl_flag = 10; // flag symbol
  D103_smbl_camp = 11; // camp symbol
  D103_smbl_circle_x = 12; // circle with x symbol
  D103_smbl_deer = 13; // deer symbol
  D103_smbl_1st_aid = 14; // first aid symbol
  D103_smbl_back_track = 15; // back track symbol

(* The enumerated values for the “dspl” member of the D103_Wpt_Type: *)
  D103_dspl_name = 0; // Display symbol with waypoint name
  D103_dspl_none = 1; // Display symbol by itself
  D103_dspl_cmnt = 2; // Display symbol with comment

(* The enumerated values for the “dspl” member of the D104_Wpt_Type: *)
  D104_dspl_smbl_none = 0; // Display symbol by itself
  D104_dspl_smbl_only = 1; // Display symbol by itself
  D104_dspl_smbl_name = 3; // Display symbol with waypoint name
  D104_dspl_smbl_cmnt = 5; // Display symbol with comment

(* The enumerated values for the “color” member of the D107_Wpt_Type: *)
  D107_clr_default = 0; // Default waypoint color
  D107_clr_red = 1; // Red
  D107_clr_green = 2; // Green
  D107_clr_blue = 3; // Blue

(* The enumerated values for the “wpt_class” member of the D108_Wpt_Type: *)
  D108_user_wpt = $00; // user waypoint
  D108_avtn_apt_wpt = $40; // aviation airport waypoint
  D108_avtn_int_wpt = $41; // aviation intersection waypoint
  D108_avtn_ndb_wpt = $42; // aviation NDB waypoint
  D108_avtn_vor_wpt = $43; // aviation VOR waypoint
  D108_avtn_arwy_wpt = $44; // aviation airport runway waypoint
  D108_avtn_aint_wpt = $45; // aviation airport intersection
  D108_avtn_andb_wpt = $46; // aviation airport ndb waypoint
  D108_map_pnt_wpt = $80; // map point waypoint
  D108_map_area_wpt = $81; // map area waypoint
  D108_map_int_wpt = $82; // map intersection waypoint
  D108_map_adrs_wpt = $83; // map address waypoint
  D108_map_line_wpt = $84; // map line waypoint

(* The “color” member can be one of the following values: *)
  D108_clr_black = 0;
  D108_clr_dark_red = 1;
  D108_clr_dark_green = 2;
  D108_clr_dark_yellow = 3;
  D108_clr_dark_blue = 4;
  D108_clr_dark_magenta = 5;
  D108_clr_dark_cyan = 6;
  D108_clr_light_gray = 7;
  D108_clr_dark_gray = 8;
  D108_clr_red = 9;
  D108_clr_green = 10;
  D108_clr_yellow = 11;
  D108_clr_blue = 12;
  D108_clr_magenta = 13;
  D108_clr_cyan = 14;
  D108_clr_white = 15;
  D108_clr_default_color = 255;

(* The valid values for the "wpt_class" member of the D110_Wpt_Type are defined as follows.
If an invalid value is received, the value shall be user_wpt. *)
  D110_user_wpt = $00; // user waypoint
  D110_avtn_apt_wpt = $40; // aviation airport waypoint
  D110_avtn_int_wpt = $41; // aviation intersection waypoint
  D110_avtn_ndb_wpt = $42; // aviation NDB waypoint
  D110_avtn_vor_wpt = $43; // aviation VOR waypoint
  D110_avtn_arwy_wpt = $44; // aviation airport runway waypoint
  D110_avtn_aint_wpt = $45; // aviation airport intersection
  D110_avtn_andb_wpt = $46; // aviation airport ndb waypoint
  D110_map_pnt_wpt = $80; // map point waypoint
  D110_map_area_wpt = $81; // map area waypoint
  D110_map_int_wpt = $82; // map intersection waypoint
  D110_map_adrs_wpt = $83; // map address waypoint
  D110_map_line_wpt = $84; // map line waypoint

(*
dspl_color - The 'dspl_color' member contains three fields; bits 0-4 specify the color, bits 5-6 specify the waypoint display attribute and bit 7 is unused and must be 0.
Valid color values are specified below. If an invalid color value is received, the value shall be Black.
Valid display attribute values are as shown below. If an invalid display attribute value is received, the value shall be Name. *)
  D110_clr_Black = 0;
  D110_clr_Dark_Red = 1;
  D110_clr_Dark_Green = 2;
  D110_clr_Dark_Yellow = 3;
  D110_clr_Dark_Blue = 4;
  D110_clr_Dark_Magenta = 5;
  D110_clr_Dark_Cyan = 6;
  D110_clr_Light_Gray = 7;
  D110_clr_Dark_Gray = 8;
  D110_clr_Red = 9;
  D110_clr_Green = 10;
  D110_clr_Yellow = 11;
  D110_clr_Blue = 12;
  D110_clr_Magenta = 13;
  D110_clr_Cyan = 14;
  D110_clr_White = 15;
  D110_clr_Transparent = 16;

  D110_dspl_Smbl_Name = 0; // Display symbol with waypoint name
  D110_dspl_Smbl_Only = 1; // Display symbol by itself
  D110_dspl_Smbl_Comment = 2; // Display symbol with comment


type
(* 7.4.18 D200_Rte_Hdr_Type
The route number contained in the D200_Rte_Hdr_Type must be unique for each route. *)
  D200_Rte_Hdr_Type = packed record
    route_number: uint8; // route number
  end;
  PD200_Rte_Hdr_Type = ^D200_Rte_Hdr_Type;

(* 7.4.19 D201_Rte_Hdr_Type
The “nmbr” member must be unique for each route. Some devices require a unique “cmnt” for each route, and other devices do not.
There is no mechanism available for the host to determine whether a device requires a unique “cmnt”, and the host
must be prepared to receive unique or non-unique “cmnt” from the device. *)
  D201_Rte_Hdr_Type = packed record
    nmbr: uint8; // route number
    cmnt: packed array [0..19] of AnsiChar; // comment
  end;
  PD201_Rte_Hdr_Type = ^D201_Rte_Hdr_Type;

(* 7.4.20 D202_Rte_Hdr_Type *)
  D202_Rte_Hdr_Type = packed record
    rte_ident: packed array [0..0] of AnsiChar; // variable length string
  end;
  PD202_Rte_Hdr_Type = ^D202_Rte_Hdr_Type;

(* 7.4.21 D210_Rte_Link_Type . The “ident” member has a maximum length of 51 characters, including the terminating NULL.
If “class” is set to “direct” or “snap”, subclass should be set to its default value of 0x0000 0x00000000 0xFFFFFFFF 0xFFFFFFFF 0xFFFFFFFF. *)
  D210_Rte_Link_Type = packed record
    rte_link_class: uint16; // link class; see below
    subclass: packed array [0..17] of Byte; // uint8; // subclass
    ident: packed array [0..0] of AnsiChar; // variable length string
  end;
  PD210_Rte_Link_Type=^D210_Rte_Link_Type;

const
(* The “class” member can be one of the following values: *)
  D210_Rte_Link_Type_class_line = 0;
  D210_Rte_Link_Type_class_link = 1;
  D210_Rte_Link_Type_class_net = 2;
  D210_Rte_Link_Type_class_direct = 3;
  D210_Rte_Link_Type_class_snap = $FF;


type
(* 7.4.33 D500_Almanac_Type *)
  D500_Almanac_Type = packed record
    wn: uint16; // week number (weeks)
    toa: float32; // almanac data reference time (s)
    af0: float32; // clock correction coefficient (s)
    af1: float32; // clock correction coefficient (s/s)
    e: float32; // eccentricity (-)
    sqrta: float32; // square root of semi-major axis (a)(m**1/2)
    m0: float32; // mean anomaly at reference time (r)
    w: float32; // argument of perigee (r)
    omg0: float32; // right ascension (r)
    odot: float32; // rate of right ascension (r/s)
    i: float32; // inclination angle (r)
  end;
  PD500_Almanac_Type = ^D500_Almanac_Type;

(* 7.4.34 D501_Almanac_Type *)
  D501_Almanac_Type = packed record
    wn: uint16; // week number (weeks)
    toa: float32; // almanac data reference time (s)
    af0: float32; // clock correction coefficient (s)
    af1: float32; // clock correction coefficient (s/s)
    e: float32; // eccentricity (-)
    sqrta: float32; // square root of semi-major axis (a)(m**1/2)
    m0: float32; // mean anomaly at reference time (r)
    w: float32; // argument of perigee (r)
    omg0: float32; // right ascension (r)
    odot: float32; // rate of right ascension (r/s)
    i: float32; // inclination angle (r)
    hlth: uint8; // almanac health
  end;
  PD501_Almanac_Type = ^D501_Almanac_Type;

(* 7.4.35 D550_Almanac_Type.     The “svid” member identifies a satellite in the GPS constellation
as follows: PRN-01 through PRN-32 are indicated by “svid” equal to 0 through 31, respectively. *)
  D550_Almanac_Type = packed record
    svid: uint8; // satellite id
    wn: uint16; // week number (weeks)
    toa: float32; // almanac data reference time (s)
    af0: float32; // clock correction coefficient (s)
    af1: float32; // clock correction coefficient (s/s)
    e: float32; // eccentricity (-)
    sqrta: float32; // square root of semi-major axis (a)(m**1/2)
    m0: float32; // mean anomaly at reference time (r)
    w: float32; // argument of perigee (r)
    omg0: float32; // right ascension (r)
    odot: float32; // rate of right ascension (r/s)
    i: float32; // inclination angle (r)
  end;
  PD550_Almanac_Type = ^D550_Almanac_Type;

(* 7.4.36 D551_Almanac_Type       The “svid” member identifies a satellite in the GPS constellation
as follows: PRN-01 through PRN-32 are indicated by “svid” equal to 0 through 31, respectively. *)
  D551_Almanac_Type = packed record
    svid: uint8; // satellite id
    wn: uint16; // week number (weeks)
    toa: float32; // almanac data reference time (s)
    af0: float32; // clock correction coefficient (s)
    af1: float32; // clock correction coefficient (s/s)
    e: float32; // eccentricity (-)
    sqrta: float32; // square root of semi-major axis (a)(m**1/2)
    m0: float32; // mean anomaly at reference time (r)
    w: float32; // argument of perigee (r)
    omg0: float32; // right ascension (r)
    odot: float32; // rate of right ascension (r/s)
    i: float32; // inclination angle (r)
    hlth: uint8; // almanac health bits 17:24 (coded)
  end;
  PD551_Almanac_Type = ^D551_Almanac_Type;

(* 7.4.37 D600_Date_Time_Type
The D600_Date_Time_Type contains the UTC date and UTC time.*)
  D600_Date_Time_Type = packed record
    month: uint8; // month (1-12)
    day: uint8; // day (1-31)
    year: uint16; // year (1990 means 1990)
    hour: uint16; // hour (0-23)
    minute: uint8; // minute (0-59)
    second: uint8; // second (0-59)
  end;
  PD600_Date_Time_Type = ^D600_Date_Time_Type;
  
type
  // generic type for all Trk_Point_Types (see above)
  TGeneric_Trk_Point_Type = packed record
    // from D302_Trk_Point_Type
    posn: position_type; // position
    time: time_type; // time
    alt: float32; // altitude in meters
    dpth: float32; // depth in meters
    temp: float32; // temp in degrees C
    new_trk: Byte; // bool; // new track segment?
    // from D304_Trk_Point_Type
    distance: float32; // distance traveled in meters. See below.
    heart_rate: uint8; // heart rate in beats per minute
    cadence: uint8; // in revolutions per minute
    sensor: Byte; // bool; // is a wheel sensor present?
  end;
  PGeneric_Trk_Point_Type = ^TGeneric_Trk_Point_Type;

  // generic type for all Trk_Hdr_Type (see above)
  TGeneric_Trk_Hdr_Type = packed record
    index: uint16; // unique among all tracks received from device
    dspl: Byte; // bool; // display on the map?
    color: uint8; // color
    trk_ident: PAnsiChar; // ansichar trk_ident[] // null-terminated string
  end;
  PGeneric_Trk_Hdr_Type = ^TGeneric_Trk_Hdr_Type;

  // Generic type for *_Wpt_Type (see above)
  TGeneric_Wpt_Type = packed record
    // from D110_Wpt_Type
    dtyp: uint8; // data packet type (0x01 for D110)
    wpt_class: uint8; // class
    dspl_color: uint8; // display & color (see below)
    attr: uint8; // attributes (0x80 for D110)
    smbl: symbol_type; // waypoint symbol
    // another part
    posn: position_type; // position
    alt: float32; // altitude in meters
    dpth: float32; // depth in meters
    dst: float32; // proximity distance in meters
    state: packed array [0..1] of AnsiChar; // state
    cc: packed array [0..1] of AnsiChar; // country code
    ete: uint32; // outbound link ete in seconds
    temp: float32; // temperature */
    time: time_type; // timestamp */
    wpt_cat: uint16; // category membership */
    // PAnsiChar instead of AnsiChar[] - NEVER FREE THIS POINTERS!
    subclass: PAnsiChar; // subclass
    ident: PAnsiChar; // variable length string
    comment: PAnsiChar; // waypoint user comment
    facility: PAnsiChar; // facility name
    city: PAnsiChar; // city name
    addr: PAnsiChar; // address number
    cross_road: PAnsiChar; // intersecting road label
    // from D108_Wpt_Type
    color: uint8; // color (see below)
    dspl: uint8; // display options (see below)
    // from D106_Wpt_Type
    lnk_ident: PAnsiChar;
  end;
  PGeneric_Wpt_Type = ^TGeneric_Wpt_Type;

  // Generic Route Header Type (see above)
  TGeneric_Rte_Hdr_Type = packed record
    route_number: Byte; // uint8; // route number
    cmnt: packed array [0..19] of AnsiChar; // comment 20 bytes max
    rte_ident: AnsiChar; // variable length string
  end;
  PGeneric_Rte_Hdr_Type = ^TGeneric_Rte_Hdr_Type;

  // Generic Almanac Type (see above)
  TGeneric_Almanac_Type = packed record
    // from D501_Almanac_Type
    wn: uint16; // week number (weeks)
    toa: float32; // almanac data reference time (s)
    af0: float32; // clock correction coefficient (s)
    af1: float32; // clock correction coefficient (s/s)
    e: float32; // eccentricity (-)
    sqrta: float32; // square root of semi-major axis (a)(m**1/2)
    m0: float32; // mean anomaly at reference time (r)
    w: float32; // argument of perigee (r)
    omg0: float32; // right ascension (r)
    odot: float32; // rate of right ascension (r/s)
    i: float32; // inclination angle (r)
    hlth: uint8; // almanac health
    // D550_Almanac_Type and D551_Almanac_Type
    svid: uint8; // satellite id ($FF means no svid field)
  end;
  PGeneric_Almanac_Type = ^TGeneric_Almanac_Type;

function semicircles_to_gradus(const value: sint32): float64;

function time_type_to_DateTime(const Atime: time_type;
                               const AWith_milliseconds: Boolean;
                               var ADateTime: TDateTime): Boolean;

implementation

uses
  DateUtils;

function semicircles_to_gradus(const value: sint32): float64;
begin
  //2**31 semicircles = 180 gradus
  //value semicircles = x gradus
  Result:=(value/semicircles_to_gradus_koeff)*180;
end;

function time_type_to_DateTime(const Atime: time_type; const AWith_milliseconds: Boolean; var ADateTime: TDateTime): Boolean;
begin
  // number of seconds since 12:00 am December 31, 1989 UTC
  // NOTE: Some devices use 0x7FFFFFFF or 0xFFFFFFFF instead of zero to indicate an invalid time value.
  if (0=Atime) or ($7FFFFFFF=Atime) or ($FFFFFFFF=Atime) then begin
    ADateTime:=0;
    Result:=FALSE;
  end else begin
    // correct value - get 2001-11-16T23:03:38Z
    Result:=TRUE;
    ADateTime:=EncodeDate(1989, 12, 31);
    ADateTime:=IncSecond(ADateTime, Atime);
  end;
end;


end.