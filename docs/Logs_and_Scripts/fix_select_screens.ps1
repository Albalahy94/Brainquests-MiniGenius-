# PowerShell script to fix all select screens
# Run this from the project root directory

$files = @(
    "lib\features\games\find_difference\ui\find_difference_select_screen.dart",
    "lib\features\games\shape_matcher\ui\shape_matcher_select_screen.dart",
    "lib\features\games\pattern_logic\ui\pattern_logic_select_screen.dart",
    "lib\features\games\quick_math\ui\quick_math_select_screen.dart",
    "lib\features\games\color_memory\ui\color_memory_select_screen.dart"
)

foreach ($file in $files) {
    Write-Host "Fixing $file..."
    
    $content = Get-Content $file -Raw
    
    # Fix 1: Change late GameProgress to nullable
    $content = $content -replace 'late GameProgress _progress;', 'GameProgress? _progress;'
    
    # Fix 2: Add mounted check in initState
    $content = $content -replace '(\s+)_storageService\.init\(\)\.then\(\(_\) \{\s+setState\(\(\) \{', '$1_storageService.init().then((_) {$1  if (mounted) {$1    setState(() {'
    $content = $content -replace '(\s+)_progress = _storageService\.getOrCreateGameProgress\(''([^'']+)''\);\s+\}\);', '$1      _progress = _storageService.getOrCreateGameProgress(''$2'');$1    });$1  }'
    
    # Fix 3: Add mounted check in _startLevel
    $content = $content -replace '(\s+)\.then\(\(_\) \{\s+// Refresh progress after returning from game\s+setState\(\(\) \{', '$1.then((_) {$1  // Refresh progress after returning from game$1  if (mounted) {$1    setState(() {'
    
    # Fix 4: Add null check in build method
    $content = $content -replace '(\s+)final gameInfo = GameDefinitions\.allGames\.firstWhere\(\s+\(g\) => g\.id == ''([^'']+)'',\s+\);', '$1final gameInfo = GameDefinitions.allGames.firstWhere($1  (g) => g.id == ''$2'',$1);$1$1if (_progress == null) {$1  return Scaffold($1    appBar: AppBar($1      title: Text(gameInfo.name),$1    ),$1    body: const Center($1      child: CircularProgressIndicator(),$1    ),$1  );$1}'
    
    # Fix 5: Add ! to _progress usages
    $content = $content -replace '(\s+)final levelProgress = _progress\.levels', '$1final levelProgress = _progress!.levels'
    $content = $content -replace '(\s+)\(_progress\.levels', '$1(_progress!.levels'
    $content = $content -replace '(\s+)final firstUnlocked = _progress\.unlockedLevels', '$1final firstUnlocked = _progress!.unlockedLevels'
    $content = $content -replace '(\s+): _progress\.completedLevels', '$1: _progress!.completedLevels'
    
    Set-Content $file $content
    Write-Host "Fixed $file ✓"
}

Write-Host "`nAll select screens fixed!"
