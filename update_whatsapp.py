import os
import re

base_dir = r"c:\Users\kifes\OneDrive\A Sites\Locaki"
css_file = os.path.join(base_dir, "css", "style.css")

css_to_append = """
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
"""

new_html_block = """
        <!-- whatsapp flutuante -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
        <a href="https://wa.me/5511971537112?text=Ol%C3%A1%20eu%20estava%20no%20site%20e%20gostaria%20de%20alugar%20itens%20para%20minha%20festa" class="whatsapp-float" target="_blank" rel="noopener" aria-label="Fale conosco pelo WhatsApp">
          <i style="margin-top:18px" class="fa fa-whatsapp"></i>
        </a>
"""

# Append CSS to style.css if not present
with open(css_file, "r", encoding="utf-8") as f:
    style_content = f.read()

if ".whatsapp-float" not in style_content:
    with open(css_file, "a", encoding="utf-8") as f:
        f.write("\n" + css_to_append)
    print("CSS appended to style.css.")
else:
    print("CSS already exists in style.css.")

# Regex patterns
css_pattern = re.compile(
    r'(?s)[ \t]*(?:/\*[^*]*whatsapp flutuante[^*]*\*/\s*)?\.whatsapp-float\s*\{.*?\@keyframes\s+pulse\s*\{(?:[^{}]*\{[^{}]*\})+\s*\}'
)
# Matches comment + link + a tag
html_pattern1 = re.compile(r'(?s)[ \t]*<!--\s*whatsapp[^-]*-->\s*<link[^>]*font-awesome[^>]*>\s*<a[^>]*class="whatsapp-float"[^>]*>[\s\S]*?</a>\s*')
# Matches anchor containing whatsapp-float class
html_pattern2 = re.compile(r'(?s)[ \t]*<a[^>]*class="whatsapp-float"[^>]*>[\s\S]*?</a>\s*')

empty_style_pattern = re.compile(r'(?s)[ \t]*<style>\s*</style>[ \t]*\n?')

updated_count = 0

for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file.endswith(".html") or file.endswith(".php"):
            filepath = os.path.join(root, file)
            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()
            except UnicodeDecodeError:
                with open(filepath, "r", encoding="latin-1") as f:
                    content = f.read()
            
            original_content = content

            # 1. Remove CSS
            content = css_pattern.sub('', content)
            content = empty_style_pattern.sub('', content)

            # 2. Remove existing HTML
            content = html_pattern1.sub('', content)
            content = html_pattern2.sub('', content)

            # 3. Add centralized HTML
            if new_html_block.strip() not in content:
                if '</footer>' in content:
                    content = content.replace('</footer>', new_html_block + '      </footer>')
                elif '</body>' in content:
                    content = content.replace('</body>', new_html_block + '</body>')
                else:
                    content += new_html_block # fallback

            if content != original_content:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(content)
                updated_count += 1

print(f"Updated {updated_count} files.")
