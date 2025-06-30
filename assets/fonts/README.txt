# Descarga la fuente NotoSans-Regular.ttf desde Google Fonts:
# https://fonts.google.com/specimen/Noto+Sans
# O usa el siguiente enlace directo:
# https://github.com/googlefonts/noto-fonts/blob/main/hinted/ttf/NotoSans/NotoSans-Regular.ttf
#
# Coloca el archivo NotoSans-Regular.ttf en esta carpeta.
#
# Luego, agrega la fuente en pubspec.yaml así:
#
# flutter:
#   fonts:
#     - family: NotoSans
#       fonts:
#         - asset: assets/fonts/NotoSans-Regular.ttf
#
# Y en el código PDF, cárgala con:
# final font = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
# ...y pásala a los TextStyle de pw.Text.
