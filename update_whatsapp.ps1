$baseDir = Get-Location
$cssFile = Join-Path $baseDir "css\style.css"

$cssToAppend = @"

/* Efeito para o botão WhatsApp flutuante */
.whatsapp-float {
    position:fixed;
    width:70px;
    height:70px;
    bottom:40px;
    right:70px;
    background: linear-gradient(135deg, #FF4CFF 60%, #B200B2 100%);
    color:#FFF;
    border-radius:50%;
    text-align:center;
    font-size:36px;
    box-shadow: 0 0 18px 4px #FF4CFF80, 0 2px 8px #888;
    z-index:1000;
    animation: pulse 1.5s infinite;
    transition: transform 0.2s, background 0.3s;
}
.whatsapp-float:hover {
    background: linear-gradient(135deg, #25d366 60%, #128c7e 100%);
    transform: scale(1.12) rotate(-3deg);
    box-shadow: 0 0 28px 8px #25d366b0, 0 2px 12px #888;
}
@keyframes pulse {
    0% { box-shadow: 0 0 18px 4px #FF4CFF80, 0 2px 8px #888; }
    50% { box-shadow: 0 0 32px 12px #FF4CFFb0, 0 2px 12px #888; }
    100% { box-shadow: 0 0 18px 4px #FF4CFF80, 0 2px 8px #888; }
}
"@

$newHtmlBlock = @"
        <!-- whatsapp flutuante -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
        <a href="https://wa.me/5511971537112?text=Ol%C3%A1%20eu%20estava%20no%20site%20e%20gostaria%20de%20alugar%20itens%20para%20minha%20festa" class="whatsapp-float" target="_blank" rel="noopener" aria-label="Fale conosco pelo WhatsApp">
          <i style="margin-top:18px" class="fa fa-whatsapp"></i>
        </a>
"@

$cssContent = Get-Content $cssFile -Raw -Encoding UTF8
if ($cssContent -notmatch "\.whatsapp-float") {
    Add-Content $cssFile -Value $cssToAppend -Encoding UTF8
    Write-Host "CSS appended to style.css."
} else {
    Write-Host "CSS already exists in style.css."
}

$cssPattern = '(?s)[\t ]*(?:/\*.*?whatsapp flutuante.*?\*/\s*)?\.whatsapp-float\s*\{.*?@keyframes\s+pulse\s*\{.*?\}\s*\}'
$htmlPattern1 = '(?s)[\t ]*<!--\s*whatsapp[^>]*-->\s*<link[^>]*font-awesome[^>]*>\s*<a[^>]*class="whatsapp-float"[^>]*>.*?</a>\s*'
$htmlPattern2 = '(?s)[\t ]*<a[^>]*class="whatsapp-float"[^>]*>.*?</a>\s*'
$emptyStylePattern = '(?s)[\t ]*<style>\s*</style>[\t ]*\r?\n?'

$files = Get-ChildItem -Path $baseDir -Recurse -Include *.html,*.php -File | Where-Object { $_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\\\." }

$updatedCount = 0

foreach ($file in $files) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $originalContent = $content

        $content = [regex]::Replace($content, $cssPattern, '')
        $content = [regex]::Replace($content, $emptyStylePattern, '')

        $content = [regex]::Replace($content, $htmlPattern1, '')
        $content = [regex]::Replace($content, $htmlPattern2, '')

        $snippetToFind = 'class="whatsapp-float"'
        if (-not $content.Contains($snippetToFind)) {
            if ($content.Contains('</footer>')) {
                $content = $content.Replace('</footer>', $newHtmlBlock + "`n      </footer>")
            } elseif ($content.Contains('</body>')) {
                $content = $content.Replace('</body>', $newHtmlBlock + "`n</body>")
            } else {
                $content += "`n" + $newHtmlBlock
            }
        }

        if ($content -cne $originalContent) {
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
            $updatedCount++
        }
    } catch {
        Write-Host "Error processing $($file.FullName): $_"
    }
}

Write-Host "Updated $updatedCount files."
