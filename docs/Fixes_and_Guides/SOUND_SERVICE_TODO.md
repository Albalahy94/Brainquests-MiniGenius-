# SoundService - TODO

## المشكلة
`AssetSource` و `Source.asset` غير موجودين في audioplayers 6.5.1

## الحل المؤقت
تم تعطيل الصوت مؤقتاً حتى يتم إصلاح API

## الحل المطلوب
تحقق من API الصحيح لـ audioplayers 6.5.1:
- قد يكون `UrlSource` أو طريقة أخرى
- راجع: https://pub.dev/packages/audioplayers

## البديل
يمكن استخدام package آخر مثل:
- `just_audio` - API أبسط وأكثر استقراراً
- `audioplayers` إصدار أقدم (5.x)

## ملاحظة
التطبيق يعمل بدون صوت - الصوت ليس ضرورياً للعمل الأساسي.

