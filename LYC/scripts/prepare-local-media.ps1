$ErrorActionPreference = 'Stop'

$ffmpeg = 'C:\Users\NINGMEI\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1-full_build\bin\ffmpeg.exe'
$root = 'D:\Codex\LYC\media\processed'
$englishDir = Join-Path $root 'english'
$poemDir = Join-Path $root 'poems'

New-Item -ItemType Directory -Force -Path $englishDir | Out-Null
New-Item -ItemType Directory -Force -Path $poemDir | Out-Null

$englishMap = @(
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Baa Baa Black Sheep - Storynory.mp3'; out = 'baa-baa-black-sheep.mp3' },
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Five Little Monkeys - Storynory.mp3'; out = 'five-little-monkeys.mp3' },
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Little Miss Muffet - Storynory.mp3'; out = 'little-miss-muffet.mp3' },
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Mary Had A Little Lamb - Storynory.mp3'; out = 'mary-had-a-little-lamb.mp3' },
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Nursery Rhymes 1 - Storynory.mp3'; out = 'nursery-rhymes-1.mp3' },
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Nursery Rhymes 2 - Storynory.mp3'; out = 'nursery-rhymes-2.mp3' },
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Twinkle Twinkle Little Star - Storynory.mp3'; out = 'twinkle-twinkle-little-star.mp3' },
  @{ src = 'D:\Codex\LYC\MP3\儿歌\英语童谣\Twinkle Twinkle Little Star Song - Storynory.mp3'; out = 'twinkle-twinkle-little-star-song.mp3' }
)

foreach ($item in $englishMap) {
  Copy-Item -LiteralPath $item.src -Destination (Join-Path $englishDir $item.out) -Force
}

$poemMap = @(
  @{ src = 'D:\Codex\LYC\MP3\诗词\单篇朗读\月下独酌 - LibriVox.m4b'; out = 'yue-xia-du-zhuo.m4a' },
  @{ src = 'D:\Codex\LYC\MP3\诗词\唐诗三百首\唐诗三百首 卷一 - LibriVox.m4b'; out = 'tangshi-300-vol-1.m4a' },
  @{ src = 'D:\Codex\LYC\MP3\诗词\唐诗三百首\唐诗三百首 卷二 - LibriVox.m4b'; out = 'tangshi-300-vol-2.m4a' },
  @{ src = 'D:\Codex\LYC\MP3\诗词\唐诗三百首\唐诗三百首 卷五 - LibriVox.m4b'; out = 'tangshi-300-vol-5.m4a' }
)

foreach ($item in $poemMap) {
  $outPath = Join-Path $poemDir $item.out
  & $ffmpeg -y -i $item.src -vn -c:a aac -b:a 64k $outPath | Out-Null
}

Get-ChildItem -LiteralPath $root -Recurse -File | Select-Object FullName, Length
