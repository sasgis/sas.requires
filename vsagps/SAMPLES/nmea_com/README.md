# NMEA COM pair - manual test tools

Two small standalone console tools for manual tests of the COM NMEA device
with a virtual serial port pair (com0com). They emulate the two ends of the
link:

- `nmea_com_sender.exe` - the **GPS receiver** side. It sends a short
  NMEA0183 stream (GGA + RMC), pauses, closes the port for several seconds
  (the "receiver is off" phase), then opens the same port again and repeats.
- `nmea_com_receiver.exe` - the **application** side. It reads the paired
  port, validates the NMEA checksums and reports the signal state:
  `SIGNAL ACQUIRED`, `SIGNAL LOST`, `SIGNAL RESTORED`.

The tools use only the Win32 API - they do not use the vsagps units, so the
receiver is an independent checker of the link. Use it to verify the port
setup and the disconnect emulation first, and then to debug the vsagps COM
device against the same sender.

## com0com setup

Create one port pair (for example COM3 <-> COM4):

- the sender opens **COM3** (the receiver/device side);
- the receiver opens **COM4** (the application side).

Both ports must be open at the same time: a write to a port whose peer is
closed blocks until the write timeout and then reports 0 bytes written (the
sender prints `the port accepted 0 bytes`). **But the bytes the driver has
already accepted are not lost** - they stay in the peer's input buffer and
are delivered when the peer port is opened next time (measured: a sentence
written to COM4 with COM3 closed arrived on COM3 three minutes later, and a
partial write may be cut in the middle of the sentence). Start the receiver
first, then the sender. The sender purges the buffers when it opens its port
and before closing it, but a reader that opens the peer port *before* the
sender can still pick up such a stale byte - this matters for the
"Access is denied" trap described below.

The loss of the signal is detected by the **data-absence timeout**, the same
idle watchdog the vsagps COM device uses (`btReceiveGPSTimeoutSec`). The
virtual pair does not report the closing of the peer port, so the silence is
the only loss indicator.

## Build

The projects are standard Delphi console projects (`AppType=Console`); the
executables go to `sas.requires\vsagps\BIN`, the DCUs to
`sas.requires\vsagps\DCU`.

- In the IDE: open `nmea_com_sender.dproj` or `nmea_com_receiver.dproj` and
  build.
- From the command line: build with the workspace environment (see
  `sas.agents\Docs\vsagps\06-notes.md` §1), for example through
  `Invoke-DelphiMsBuild` from `sas.agents\Tools\BuildEnv.ps1`:

  ```powershell
  . .\sas.agents\Tools\BuildEnv.ps1
  $p = ".\sas.requires\vsagps\SAMPLES\nmea_com"
  Invoke-DelphiMsBuild -ProjectPath "$p\nmea_com_sender.dproj" `
      -Config Debug -Platform Win32 -WorkingDirectory $p
  Invoke-DelphiMsBuild -ProjectPath "$p\nmea_com_receiver.dproj" `
      -Config Debug -Platform Win32 -WorkingDirectory $p
  ```

## Usage

Start the receiver, then the sender:

```
BIN\nmea_com_receiver.exe /port=COM4 /timeout=3000
BIN\nmea_com_sender.exe /port=COM3 /count=10 /interval=200 /pause=2000 /offline=5000
```

The receiver output on a normal cycle:

```
17:10:31.417 port COM4 opened, waiting for the NMEA stream
17:10:32.244 *** SIGNAL ACQUIRED ***
17:10:33.318 signal ON: sentences=9 (GGA=5 RMC=4 other=0) bad=0 bytes=627 last=GPGGA
17:10:34.542 signal ON: sentences=10 (GGA=5 RMC=5 other=0) bad=0 bytes=695 last=GPRMC
17:10:35.602 *** SIGNAL LOST: no data for 2000 ms ***
17:10:37.550 *** SIGNAL RESTORED after 4078 ms of silence ***
```

The sender output:

```
17:10:32.244 cycle 1: opening COM3 (4800 baud, 8N1)
17:10:32.244 cycle 1: port opened (emulated GPS is on)
17:10:33.502 cycle 1: sent 10 sentences, pause 1000 ms (port stays open)
17:10:34.526 cycle 1: port COM3 closed (emulated GPS is off for 3000 ms)
17:10:37.550 cycle 2: opening COM3 (4800 baud, 8N1)
```

`Ctrl+C` stops either tool and prints a summary. `/cycles=N` stops after N
cycles (the sender) or N signal acquisitions (the receiver) - handy for
automated runs.

### nmea_com_sender options

| Option | Default | Meaning |
|---|---|---|
| `/port=NAME` | `COM3` | the port to write to |
| `/baud=N` | `4800` | the baud rate (8N1) |
| `/count=N` | `10` | sentences per cycle (GGA/RMC pairs) |
| `/interval=MS` | `200` | delay between sentences |
| `/pause=MS` | `2000` | silent pause before the port is closed |
| `/offline=MS` | `5000` | the port stays closed |
| `/cycles=N` | `0` | stop after N cycles, 0 = endless |
| `/verbose` | off | print every transmitted/received sentence |

### nmea_com_receiver options

| Option | Default | Meaning |
|---|---|---|
| `/port=NAME` | `COM4` | the port to read |
| `/baud=N` | `4800` | the baud rate (8N1) |
| `/timeout=MS` | `3000` | no-data timeout which reports the signal loss |
| `/cycles=N` | `0` | stop after N signal acquisitions, 0 = endless |
| `/verbose` | off | print every received sentence |

## What to check

- Both ports open and the receiver shows `SIGNAL ACQUIRED` - the pair works.
- During the sender pause/offline phase the receiver shows `SIGNAL LOST`
  after `/timeout`; when the sender opens the port again it shows
  `SIGNAL RESTORED`.
- `bad checksums=0` in the receiver summary - the NMEA framing and the
  checksums are correct.
- With `/verbose` the sender also prints the queries the application sends
  (the vsagps COM device sends an RMC query at the session start).

## Troubleshooting: `cannot open COM3: Access is denied`

A COM port in Windows is opened exclusively (share mode 0), so the message
means **somebody else holds COM3 right now**. The sender keeps retrying once
per second, so the run continues as soon as the port is released. The usual
holders:

- **a second sender instance** (or a console window left over from an earlier
  run) - check Task Manager / `Get-Process nmea_com_sender`;
- **the application under test**, if its COM device is configured with
  **"Autodetect port on connect"** (SAS.Planet: GPS device settings -> the
  "Autodetect port on connect" group). vsagps then enumerates all COM ports
  from `HKLM\HARDWARE\DEVICEMAP\SERIALCOMM` and opens **each of them**
  exclusively (`VSAGPS\RUNTIME\vsagps_com_checker.pas`,
  `CreateFile(..., GENERIC_READ or GENERIC_WRITE, 0, ...)`) for up to the
  connection timeout, and it **keeps the handle** of the first port that
  produced data (`ExtractFirstOpenedHandle` -> `FGPSDeviceHandle` in
  `vsagps_device_com_nmea.pas`). Combined with the stale-byte buffering above
  this is a real trap: a query written by the application while the sender
  was "off" waits in the sender's port buffer, the autodetect scan opens that
  port, reads the stale bytes, decides that this is the GPS and keeps the
  handle for the whole session - the sender then can never reopen its port
  (`Access is denied`, the application at the same time sees no data). Fix:
  clear the autodetect checkboxes and select the port explicitly (COM4).

To see who holds the port, use Sysinternals `handle64.exe COM3` or Process
Explorer (Find -> Find Handle or DLL -> `\Device\com0com21`).
