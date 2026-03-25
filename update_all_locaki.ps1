$baseDir = Get-Location

# 1. Blocks to inject
$whatsappHtml = @"
        <!-- whatsapp flutuante -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
        <a href="https://wa.me/5511971537112?text=Ol%C3%A1%20eu%20estava%20no%20site%20e%20gostaria%20de%20alugar%20itens%20para%20minha%20festa" class="whatsapp-float" target="_blank" rel="noopener" aria-label="Fale conosco pelo WhatsApp">
          <i style="margin-top:18px" class="fa fa-whatsapp"></i>
        </a>
"@

# 2. Gather valid HTML files for Menu and Sitemap
$htmlFiles = Get-ChildItem -Path $baseDir -Filter *.html -File | Where-Object { 
    $_.Name -notmatch "error_log|google.*\.html|xxxmodelo|.*-.*_ogoogle|--|googlemaps|gooqlemaps|update_" 
}

$menuItems = ""
$sitemapUrls = ""
$today = Get-Date -Format "yyyy-MM-dd"

$sitemapUrls += @"
  <url>
    <loc>https://www.locaki.com.br/</loc>
    <lastmod>$today</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
"@

foreach ($f in $htmlFiles) {
    if ($f.Name -eq "index.html" -or $f.Name -eq "index2.html") { continue }
    
    # Format name nicely
    $text = $f.BaseName.Replace('_', ' ').Replace('-', ' ')
    $text = (Get-Culture).TextInfo.ToTitleCase($text.ToLower())
    
    $menuItems += "          <li><a href=`"$($f.Name)`">$text</a></li>`n"
    
    $sitemapUrls += @"
  <url>
    <loc>https://www.locaki.com.br/$($f.Name)</loc>
    <lastmod>$today</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
"@
}

$newMenuHtml = @"
      <!-- Menu "Mais páginas" -->
      <div class="footer-menu-container">
        <h6 class="text-spacing-100 text-uppercase" id="mais-paginas" style="cursor:pointer; margin-top:30px; text-align:center; color:white;">Mais páginas</h6>
        <ul class="footer-menu" id="footer-menu" style="display:none; text-align:center; list-style:none; padding:0;">
$menuItems
        </ul>
      </div>
      <script>
        if(document.getElementById('mais-paginas')){
            document.getElementById('mais-paginas').addEventListener('click', function() {
                var menu = document.getElementById('footer-menu');
                if(menu.style.display === 'none') {
                    menu.style.display = 'block';
                } else {
                    menu.style.display = 'none';
                }
            });
        }
      </script>
"@

# Write Sitemap
$sitemapContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
$sitemapUrls
</urlset>
"@
[System.IO.File]::WriteAllText((Join-Path $baseDir "sitemap.xml"), $sitemapContent, [System.Text.Encoding]::UTF8)
Write-Host "Sitemap generated."

# Regexes for Cleanup
# 3.1 CSS WhatsApp Flutuante removal (very aggressive inside <style> tags)
# Find .whatsapp-float inside <style> and remove it completely 

$files = Get-ChildItem -Path $baseDir -Recurse -Include *.html,*.php -File | Where-Object { $_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\\\." }
$updatedCount = 0

foreach ($file in $files) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        $originalContent = $content

        # 1. Clean up CSS inline blocks (.whatsapp-float)
        # Remove anything from .whatsapp-float to its closing brace, handling pseudo classes
        $content = [regex]::Replace($content, '(?s)[\t ]*(?:/\*[^\*]*whatsapp[^\*]*\*/\s*)?\.whatsapp-float\s*\{[^\}]*\}[ \t]*\r?\n?', '')
        $content = [regex]::Replace($content, '(?s)[\t ]*\.whatsapp-float:hover\s*\{[^\}]*\}[ \t]*\r?\n?', '')
        # Remove old keyframes pulse if leftover
        $content = [regex]::Replace($content, '(?s)[\t ]*@keyframes\s+pulse\s*\{.*?\}[ \t]*\r?\n?', '')

        # Remove completely empty style blocks
        $content = [regex]::Replace($content, '(?s)[\t ]*<style>\s*</style>[ \t]*\r?\n?', '')

        # 2. Clean up Old Whatsapp Anchor HTML
        $content = [regex]::Replace($content, '(?s)[\t ]*<!--\s*whatsapp[^-]*-->\s*<link[^>]*font-awesome[^>]*>\s*<a[^>]*class="whatsapp-float"[^>]*>.*?</a>\s*', '')
        $content = [regex]::Replace($content, '(?s)[\t ]*<a[^>]*class="whatsapp-float"[^>]*>.*?</a>\s*', '')

        # 3. Clean up the Mais Páginas Menu
        # Look for <div class="footer-menu-container"> ... </div> or <ul class="footer-menu"...
        $content = [regex]::Replace($content, '(?s)[\t ]*<div[^>]*class="footer-menu-container"[^>]*>.*?</div>\s*', '')
        $content = [regex]::Replace($content, '(?s)[\t ]*<ul[^>]*id="footer-menu"[^>]*>.*?</ul>\s*', '')
        $content = [regex]::Replace($content, '(?s)[\t ]*<h6[^>]*id="mais-paginas"[^>]*>.*?</h6>\s*', '')
        # Remove the toggle JS script if it exists
        $content = [regex]::Replace($content, '(?s)[\t ]*// Função para abrir/fechar o menu ao clicar no título "Mais páginas"\s*(?:if\s*\(\s*document\.getElementById.*?)?document\.getElementById\(''''mais-paginas''''\).*?\}[ \t]*\r?\n?(?:\}[ \t]*\r?\n?)?', '')

        # 4. Inject the Standard Whatsapp HTML (before </footer> or </body>)
        if ($content.Contains('</footer>')) {
            $content = $content.Replace('</footer>', $whatsappHtml + "`n      </footer>")
        } elseif ($content.Contains('</body>')) {
            $content = $content.Replace('</body>', $whatsappHtml + "`n</body>")
        } else {
            $content += "`n" + $whatsappHtml
        }

        # 5. Inject the Mais Paginas exclusively in index.html
        if ($file.Name -eq "index.html") {
            if ($content.Contains('</footer>')) {
                $content = $content.Replace('</footer>', "`n" + $newMenuHtml + "`n      </footer>")
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

Write-Host "Updated $updatedCount HTML files."
