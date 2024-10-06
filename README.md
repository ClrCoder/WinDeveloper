# ClrCoder / Windows Developer
Set of scripts, tweaks, and utilities to help tune/maintain a Windows machine for development purposes.

## Windows Settings
### Keyboard
Default windows settings limiting typing/editing/navigation speed in the text editor.
Default settings is **250 ms** delay before repeating of a pressed key and **30** repeats/seconds rate.  
With a good keyboard, human reaction allows precise control with a **200 ms** delay and **60** repeats/second, which can significantly speed up typing, navigation, and character deletion.

> [!IMPORTANT]
> You need to tune the latency of your system, otherwise you may encounter the **false repeat** problem with these aggressive settings.

| Setting                                            | Values                                                           |
| ---------------------------------------------------| ---------------------------------------------------------------- |
| `winSettings.keyboard.standardRepeatDelay`         | 0 = 250ms (recommended) <br/>1 ~ 0.5ms (default)<br/>3 ~ 1 s delay.
| `winSettings.keyboard.standardSpeed`               | 0 = 2.5 char/sec <br/> 31 ~ 30 chars/sec (default).
| `winSettings.keyboard.filteredKeys.enabled`        | true = advanced settings enabled, false = only standard settings |
| `winSettings.keyboard.filteredKeys.repeatDelay`    | Time in ms before keys auto repeats, 200 ms recommended          |
| `winSettings.keyboard.filteredKeys.repeatInterval` | Interval between key repeats in ms, set 10 to have maximum supported 60 chars/sec repeat rate (recommended) |
