import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Recupera a chave da API do Info.plist.
    guard let googleMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSServicesAPIKey") as? String, !googleMapsApiKey.hasPrefix("$(") else {
      fatalError("Chave da API do Google Maps não encontrada ou não configurada no Info.plist. Verifique sua configuração.")
    }

    GMSServices.provideAPIKey(googleMapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
