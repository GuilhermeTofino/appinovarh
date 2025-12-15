# appinovarh

App Flutter para telemetria em tempo real, mostrando localização no mapa, velocidade, aceleração e direção.

## Configuração

### Dependências
As dependências já estão adicionadas no pubspec.yaml:
- geolocator: ^12.0.0
- sensors_plus: ^6.0.0
- google_maps_flutter: ^2.10.0
- provider: ^6.1.2

Execute `flutter pub get` para instalar.

### Permissões
Permissões já configuradas para Android e iOS.

### Google Maps API
Para usar o mapa, você precisa de uma chave API do Google Maps.

1. Vá para [Google Cloud Console](https://console.cloud.google.com/).
2. Crie um projeto ou selecione um existente.
3. Ative a API do Maps SDK for Android e Maps SDK for iOS.
4. Crie uma chave API.

#### Configurando a Chave de API
Para proteger sua chave de API, ela não deve ser versionada no Git. As instruções variam por plataforma.

##### Android
O sistema de build do Android está configurado para ler a chave de um arquivo `.env`.

1. Crie um arquivo chamado `.env` na raiz do projeto (se ainda não existir).
2. Adicione sua chave ao arquivo:
   ```
   GOOGLE_MAPS_API_KEY=SUA_CHAVE_DE_API_AQUI
   ```
3. O arquivo `.env` já está no `.gitignore` para evitar que seja enviado ao repositório.

##### iOS
O sistema de build do iOS usa um arquivo de configuração do Xcode (`.xcconfig`) para gerenciar a chave.

1. Na pasta `ios/Flutter/`, crie um arquivo chamado `Maps.xcconfig`.
2. Adicione sua chave ao arquivo:
   ```
   GOOGLE_MAPS_API_KEY=SUA_CHAVE_DE_API_AQUI
   ```
3. O arquivo `ios/Flutter/Maps.xcconfig` já está no `.gitignore`.
```

## Executando
Execute `flutter run` para rodar o app.

O app mostra um mapa com marcador na posição atual, velocidade, aceleração e direção. Use o botão flutuante para iniciar/parar a coleta de dados.
