# Skill Tree Reforged

A Witcher 3 Remastered (5.0) mod that lets you pick how skills unlock.

The Remastered update reworked the skill trees so that most skills need one or more prerequisite skills before you can buy them. Some people like that. Others miss being able to grab the skill they actually want. This mod adds a setting for it instead of forcing one way on everyone.

## Unlock rules

Pick one under Options > Mods > Skill Tree Reforged.

| Mode | What it does |
| --- | --- |
| Remastered | Unchanged game behaviour. This is the default. |
| Classic | Prerequisites are ignored. Each tree opens up in tiers again: the top two rows are available right away and every further tier needs 6 more points spent in that tree (6, 12, 18, 24). Perks unlock by distance from the centre column instead. |
| Flexible | A skill opens up if you own one of its prerequisites or if you have spent enough points in the tree for its tier, whichever comes first. |
| Free | Everything can be learned as long as you have the points. |

Points spent in a tree are counted from the ranks you actually own, so they stay correct after loading a save or using a Potion of Clearance. In Classic and Flexible, the tooltip of a skill that is still locked by its tier tells you how many points it needs.

Skill costs, ranks and the number of points you get are not touched. Switching modes does not remove skills you already learned. If you learned something in a looser mode and switch back to a stricter one, the skill menu marks it red because its requirement is missing. The skill keeps working, you just can't buy further ranks until the requirement is met.

## Original skill tree (4.0)

Set "Skill tree" to "Original (4.0)" to play with the skill tree from before the Remastered update. All 80 old skills are back in the character menu in their old layout: five columns per tree, four tiers each, and the 20 old general skills. The old skills still work in the game code, the mod only brings them back into the menu.

Tiers work like they used to. The first row is open right away, the next rows need 6, 12 and 18 points spent in that tree. If the unlock rule is set to Free, every skill is open. The other unlock rules make no difference in the original tree.

Skill trees are stored per save. When you open the character menu and the save still uses the other tree, the game asks before switching. Switching resets all skills and refunds every point, mutagens go back to your inventory and mutations are kept. If you say no, the setting goes back to the tree of that save. If you have not learned anything yet, or only skills that exist in both trees, the switch happens without asking.

Known limits:
- The old menu drew lock icons next to each tier. The new menu has no place for them, locked rows are dimmed and the tooltip tells you how many points are missing.
- Flood of Anger raises sign skills to their maximum level while it lasts. Since 5.0 that only covers sign skills of the new tree, so old sign skills like Firestream keep their own level.
- Switch back to Remastered before uninstalling. Old skills stay learned in your save but the vanilla menu cannot show them, so their points would be stuck until you use a Potion of Clearance.

## Hybrid tree

Set "Skill tree" to "Hybrid (5.0 + 4.0)" to keep the whole Remastered tree and get a few old skills back on top. They sit in free spots of the new tree and hang off a Remastered skill, so you buy that one first. Only old skills that still work in the game code and don't overlap with a new skill are included:

| Tree | Skill | Requires |
| --- | --- | --- |
| Combat | Crushing Blows | Strength Training |
| Combat | Precise Blows | Muscle Memory |
| Combat | Crippling Strikes (old version with bleeding) | Crippling Strike |
| Signs | Quen Discharge | Fortify Signs |
| Alchemy | Heightened Tolerance | Toxic Shock |
| Alchemy | Fixative | Protective Coating |
| Alchemy | Killing Spree | Debilitating Poison |
| General | Gorged on Power | Adrenaline Burst |
| General | Heavy Artillery | Advanced Pyrotechnics |

The unlock rules work as usual. In Classic the extra skills use the tier of the row they sit in.

This is stored per save like the original tree. Switching from Remastered to this option never resets anything. Switching away from it while you own one of the classic skills asks first and resets your skills.

## Respec

With "Keep Potion of Clearance after use" turned on (Options > Mods > Skill Tree Reforged, off by default), drinking a Potion of Clearance still resets your skills as usual, but the potion stays in your inventory. That makes respecs free for as long as you own one. Mutations and the Potion of Restoration are not affected.

## Languages

Menu texts are in English, German, Polish, Russian, Ukrainian, French, Spanish, Italian, Brazilian Portuguese, Simplified and Traditional Chinese, Japanese, Korean and Czech. Potion and menu terms are taken from the game's own translations. Translations other than English and German may be imperfect, corrections are welcome. Other game languages show the English texts.

## Install

Copy the `mods` and `bin` folders from the archive into your game folder (the one that contains `content`). Scripts are compiled when the game starts.

To uninstall, switch the skill tree back to Remastered first if you use one of the other trees, then delete `mods\modSkillTreeReforged` and `bin\config\r4game\user_config_matrix\pc\modSkillTreeReforged.xml`.

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
