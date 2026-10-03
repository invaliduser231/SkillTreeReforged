# Skill Tree Reforged

A Witcher 3 Remastered (5.0) mod that lets you pick how skills unlock.

The Remastered update reworked the skill trees so that most skills need one or more prerequisite skills before you can buy them. Some people like that. Others miss being able to grab the skill they actually want. This mod adds a setting for it instead of forcing one way on everyone.

## Unlock rules

Pick one under Options > Mods > Skill Tree Reforged.

| Mode | What it does |
| --- | --- |
| Remastered | Unchanged game behaviour. This is the default. |
| Classic | Prerequisites are ignored. Skills open up once you have spent enough points in that tree, like before 5.0. |
| Loose | Owning any one of the listed prerequisites is enough. |
| Free | Everything can be learned as long as you have the points. |

Skill costs, ranks and the number of points you get are not touched. Switching modes does not remove skills you already learned.

## Install

Copy the `mods` and `bin` folders from the archive into your game folder (the one that contains `content`). Scripts are compiled when the game starts.

To uninstall, delete `mods\modSkillTreeReforged` and `bin\config\r4game\user_config_matrix\pc\modSkillTreeReforged.xml`.

## Compatibility

Requires game version 5.0 or newer. No game scripts are replaced, the mod hooks into the skill checks with annotations, so Script Merger is not needed. Other mods that change how skills unlock will probably conflict.

## Building from source

Windows with PowerShell 7.

```
tools\check.ps1
tools\build.ps1
tools\deploy.ps1 -GamePath "D:\Games\The Witcher 3"
```

`build.ps1` needs a w3strings encoder for the menu texts. Point `W3STRINGS_ENCODER` at it, otherwise the menu shows raw string keys.

## License

MIT
