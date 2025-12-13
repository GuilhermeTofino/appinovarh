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
Para proteger sua chave, ela é carregada a partir de um arquivo `.env` que não é versionado.
1. Crie um arquivo chamado `.env` na raiz do projeto.
2. Adicione sua chave ao arquivo da seguinte forma:
   ```
   GOOGLE_MAPS_API_KEY=SUA_CHAVE_DE_API_AQUI
   ```
O sistema de build do Android e iOS está configurado para injetar essa chave automaticamente durante a compilação.
```

## Executando
Execute `flutter run` para rodar o app.

O app mostra um mapa com marcador na posição atual, velocidade, aceleração e direção. Use o botão flutuante para iniciar/parar a coleta de dados.
