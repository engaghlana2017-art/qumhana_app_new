import os

# إضافة أمر تفعيل الأوفلاين الدائم للـ Gradle
gradle_props_path = r'android\gradle.properties'
offline_line = "org.gradle.offline=true\n"

if os.path.exists(gradle_props_path):
    with open(gradle_props_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "org.gradle.offline" not in content:
        with open(gradle_props_path, 'a', encoding='utf-8') as f:
            f.write("\n" + offline_line)
        print("تم تفعيل وضع الأوفلاين الدائم في Gradle بنجاح!")
    else:
        print("وضع الأوفلاين مفعل مسبقاً.")
else:
    print("خطأ: تأكد أنك في مجلد المشروع الرئيسي.")