const fs = require('fs');
const path = require('path');

const baseDir = __dirname;
const cssFile = path.join(baseDir, 'css', 'style.css');

const cssToAppend = `
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
`;

const newHtmlBlock = `
        <!-- whatsapp flutuante -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
        <a href="https://wa.me/5511971537112?text=Ol%C3%A1%20eu%20estava%20no%20site%20e%20gostaria%20de%20alugar%20itens%20para%20minha%20festa" class="whatsapp-float" target="_blank" rel="noopener" aria-label="Fale conosco pelo WhatsApp">
          <i style="margin-top:18px" class="fa fa-whatsapp"></i>
        </a>
`;

// Append CSS to style.css if not present
let styleContent = fs.readFileSync(cssFile, 'utf-8');
if (!styleContent.includes('.whatsapp-float')) {
    fs.appendFileSync(cssFile, "\n" + cssToAppend, 'utf-8');
    console.log("CSS appended to style.css.");
} else {
    console.log("CSS already exists in style.css.");
}

// Regex patterns
const cssPattern = /(?:[ \t]*\/\*[\s\S]*?whatsapp flutuante[\s\S]*?\*\/[ \t]*[\r\n]*)?\.whatsapp-float\s*\{[\s\S]*?@keyframes\s+pulse\s*\{[\s\S]*?\}\s*\}/g;

const htmlPattern1 = /[ \t]*<!--\s*whatsapp[^-]*-->\s*<link[^>]*font-awesome[^>]*>\s*<a[^>]*class="whatsapp-float"[^>]*>[\s\S]*?<\/a>\s*/g;
const htmlPattern2 = /[ \t]*<a[^>]*class="whatsapp-float"[^>]*>[\s\S]*?<\/a>\s*/g;

const emptyStylePattern = /[ \t]*<style>\s*<\/style>[ \t]*\r?\n?/g;

let updatedCount = 0;

function processDirectory(dir) {
    const files = fs.readdirSync(dir);
    
    for (const file of files) {
        if (file === 'node_modules' || file.startsWith('.')) continue;
        
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);
        
        if (stat.isDirectory()) {
            processDirectory(filePath);
        } else if (file.endsWith('.html') || file.endsWith('.php')) {
            try {
                let content = fs.readFileSync(filePath, 'utf-8');
                const originalContent = content;

                // 1. Remove CSS
                content = content.replace(cssPattern, '');
                content = content.replace(emptyStylePattern, '');

                // 2. Remove existing HTML
                content = content.replace(htmlPattern1, '');
                content = content.replace(htmlPattern2, '');

                // 3. Add centralized HTML
                if (!content.includes(newHtmlBlock.trim())) {
                    if (content.includes('</footer>')) {
                        content = content.replace('</footer>', newHtmlBlock + '      </footer>');
                    } else if (content.includes('</body>')) {
                        content = content.replace('</body>', newHtmlBlock + '</body>');
                    } else {
                        content += newHtmlBlock;
                    }
                }

                if (content !== originalContent) {
                    fs.writeFileSync(filePath, content, 'utf-8');
                    updatedCount++;
                }
            } catch (err) {
                console.error("Error reading file:", filePath, err.message);
            }
        }
    }
}

processDirectory(baseDir);
console.log("Updated", updatedCount, "files.");
