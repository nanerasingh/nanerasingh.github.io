#!/bin/bash
# Regenerate repo index files for both Cydia and Sileo support
python3 -c "
import glob, io, tarfile, hashlib, os, bz2, gzip, lzma

depiction_map = {
    'com.manu.battery': ('https://nanerasingh.github.io/depicts/Battery/Battery.html', 'https://nanerasingh.github.io/depicts/com.manu.battery.json'),
    'com.manu.dialergradient': ('https://nanerasingh.github.io/depicts/DialerGradient/DialerGradient.html', 'https://nanerasingh.github.io/depicts/com.manu.dialergradient.json'),
    'com.nanerasingh.dialergradientx': ('https://nanerasingh.github.io/depicts/DialerGradient/DialerGradient.html', 'https://nanerasingh.github.io/depicts/com.manu.dialergradient.json'),
    'com.manu.flashsound': ('https://nanerasingh.github.io/depicts/FlashSound/FlashSound.html', 'https://nanerasingh.github.io/depicts/com.manu.flashsound.json'),
    'com.manu.gradientgububblecolor': ('https://nanerasingh.github.io/depicts/GradientBubble/GradientBubble.html', 'https://nanerasingh.github.io/depicts/com.manu.gradientgububblecolor.json'),
    'com.nanerasingh.gradientbubblex': ('https://nanerasingh.github.io/depicts/GradientBubble/GradientBubble.html', 'https://nanerasingh.github.io/depicts/com.manu.gradientgububblecolor.json'),
    'com.manu.MinimulHudVibrate': ('https://nanerasingh.github.io/depicts/MinimulHudVibrate/MinimulHudVibrate.html', 'https://nanerasingh.github.io/depicts/com.manu.minimulhudvibrate.json'),
    'com.manu.networkcc': ('https://nanerasingh.github.io/depicts/NetworkCC/NetworkCC.html', 'https://nanerasingh.github.io/depicts/com.manu.networkcc.json'),
    'com.nanerasingh.networkccmodulesx': ('https://nanerasingh.github.io/depicts/NetworkCCX/NetworkCCX.html', 'https://nanerasingh.github.io/depicts/com.manu.networkccx.json'),
    'com.manu.networkccx': ('https://nanerasingh.github.io/depicts/NetworkCCX/NetworkCCX.html', 'https://nanerasingh.github.io/depicts/com.manu.networkccx.json'),
    'com.manu.scrolltodismisskeyboard': ('https://nanerasingh.github.io/depicts/ScrollToDismissKeyBaord/ScrollToDismissKeyBaord.html', 'https://nanerasingh.github.io/depicts/com.manu.scrolltodismisskeyboard.json'),
    'com.manu.time': ('https://nanerasingh.github.io/depicts/Time/Time.html', 'https://nanerasingh.github.io/depicts/com.manu.time.json'),
    'com.manu.theosmanagerpro': ('https://nanerasingh.github.io/depicts/TheosManagerPro/TheosManagerPro.html', 'https://nanerasingh.github.io/depicts/com.manu.theosmanagerpro.json'),
    'com.nanerasingh.theosmanager': ('https://nanerasingh.github.io/depicts/TheosManagerPro/TheosManagerPro.html', 'https://nanerasingh.github.io/depicts/com.manu.theosmanagerpro.json'),
    'com.manu.autoscrollx': ('https://nanerasingh.github.io/depicts/AutoScrollx/AutoScrollx.html', 'https://nanerasingh.github.io/depicts/com.manu.autoscrollx.json'),
    'com.manu.nceffectspro': ('https://nanerasingh.github.io/depicts/NCEffectsPro/NCEffectsPro.html', 'https://nanerasingh.github.io/depicts/com.manu.nceffectspro.json'),
    'com.nanerasingh.nceffectspro': ('https://nanerasingh.github.io/depicts/NCEffectsPro/NCEffectsPro.html', 'https://nanerasingh.github.io/depicts/com.manu.nceffectspro.json'),
    'com.manu.screenfreezex': ('https://nanerasingh.github.io/depicts/ScreenFreezeX/ScreenFreezeX.html', 'https://nanerasingh.github.io/depicts/com.manu.screenfreezex.json'),
    'com.nanerasingh.screenfreezex': ('https://nanerasingh.github.io/depicts/ScreenFreezeX/ScreenFreezeX.html', 'https://nanerasingh.github.io/depicts/com.manu.screenfreezex.json'),
    'com.manu.lastunlockx': ('https://nanerasingh.github.io/depicts/LastUnlockX/LastUnlockX.html', 'https://nanerasingh.github.io/depicts/com.manu.lastunlockx.json'),
    'com.manu.fullscreenshot': ('https://nanerasingh.github.io/depicts/Fullscreenshot/Fullscreenshot.html', 'https://nanerasingh.github.io/depicts/com.manu.fullscreenshot.json'),
    'com.nanerasingh.fullscreenshot': ('https://nanerasingh.github.io/depicts/Fullscreenshot/Fullscreenshot.html', 'https://nanerasingh.github.io/depicts/com.manu.fullscreenshot.json')
}

def auto_resolve_depiction(pkg_id):
    if pkg_id in depiction_map:
        return depiction_map[pkg_id]
    
    clean_name = pkg_id.split('.')[-1].lower()
    html_url, json_url = None, None
    
    if os.path.exists('depicts'):
        for folder in os.listdir('depicts'):
            folder_path = os.path.join('depicts', folder)
            if os.path.isdir(folder_path) and folder.lower() == clean_name:
                for file in os.listdir(folder_path):
                    if file.endswith('.html'):
                        html_url = f'https://nanerasingh.github.io/depicts/{folder}/{file}'
                        break
                break
        
        json_file = f'depicts/{pkg_id.lower()}.json'
        if os.path.exists(json_file):
            json_url = f'https://nanerasingh.github.io/{json_file}'

    return (html_url, json_url)

def extract_control(data):
    if not data.startswith(b'!<arch>\n'): return None
    pos = 8
    while pos < len(data):
        h = data[pos:pos+60]
        if len(h) < 60: break
        name = h[:16].decode('latin1').strip()
        try: size = int(h[48:58].decode('latin1').strip())
        except ValueError: break
        dp = pos + 60
        fdata = data[dp:dp+size]
        pos = dp + size + (size % 2)
        if name.startswith('control.tar'):
            try:
                tf = tarfile.open(fileobj=io.BytesIO(fdata))
                for m in tf.getmembers():
                    if m.name in ('./control', 'control'):
                        return tf.extractfile(m).read().decode('utf-8', errors='ignore')
            except Exception: pass
    return None

entries = []
deb_files = sorted(glob.glob('pkgs/*.deb'))
print(f'Found {len(deb_files)} .deb package(s) in pkgs/...')

for deb_path in deb_files:
    with open(deb_path, 'rb') as f: data = f.read()
    ctrl = extract_control(data)
    if not ctrl:
        print(f'⚠️ Warning: Could not extract control file from {deb_path}')
        continue
    lines = ctrl.strip().split('\n')
    pkg_id = ''
    has_dep = has_sileo = False
    for l in lines:
        if l.startswith('Package: '): pkg_id = l.split(': ', 1)[1].strip()
        elif l.lower().startswith('depiction:'): has_dep = True
        elif l.lower().startswith('sileodepiction:'): has_sileo = True
    lines.extend([
        f'Filename: {deb_path}',
        f'Size: {len(data)}',
        f'MD5sum: {hashlib.md5(data).hexdigest()}',
        f'SHA1: {hashlib.sha1(data).hexdigest()}',
        f'SHA256: {hashlib.sha256(data).hexdigest()}'
    ])
    html_url, json_url = auto_resolve_depiction(pkg_id)
    if html_url and not has_dep: lines.append(f'Depiction: {html_url}')
    if json_url and not has_sileo: lines.append(f'SileoDepiction: {json_url}')
    entries.append('\n'.join(lines))

pkg_bytes = ('\n\n'.join(entries) + '\n').encode('utf-8')

with open('Packages', 'wb') as f:
    f.write(pkg_bytes)

with open('Packages.bz2', 'wb') as f:
    f.write(bz2.compress(pkg_bytes))

with open('Packages.gz', 'wb') as f:
    f.write(gzip.compress(pkg_bytes))

with open('Packages.xz', 'wb') as f:
    f.write(lzma.compress(pkg_bytes))

print(f'✅ Successfully updated Packages, Packages.bz2, Packages.gz, and Packages.xz with {len(entries)} package entries!')
"
