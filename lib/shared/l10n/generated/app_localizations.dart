import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// Application title
  ///
  /// In pt_BR, this message translates to:
  /// **'Backstage Cinema'**
  String get appTitle;

  /// No description provided for @common_ok.
  ///
  /// In pt_BR, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In pt_BR, this message translates to:
  /// **'Excluir'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar'**
  String get common_edit;

  /// No description provided for @common_back.
  ///
  /// In pt_BR, this message translates to:
  /// **'Voltar'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In pt_BR, this message translates to:
  /// **'Próximo'**
  String get common_next;

  /// No description provided for @common_search.
  ///
  /// In pt_BR, this message translates to:
  /// **'Buscar'**
  String get common_search;

  /// No description provided for @common_filter.
  ///
  /// In pt_BR, this message translates to:
  /// **'Filtrar'**
  String get common_filter;

  /// No description provided for @common_loading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carregando...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sucesso'**
  String get common_success;

  /// No description provided for @common_confirm.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar'**
  String get common_confirm;

  /// No description provided for @login_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Bem-vindo ao Backstage'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sistema de gerenciamento de cinema'**
  String get login_subtitle;

  /// No description provided for @login_cpf_label.
  ///
  /// In pt_BR, this message translates to:
  /// **'CPF'**
  String get login_cpf_label;

  /// No description provided for @login_cpf_hint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite seu CPF'**
  String get login_cpf_hint;

  /// No description provided for @login_password_label.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha'**
  String get login_password_label;

  /// No description provided for @login_password_hint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite sua senha'**
  String get login_password_hint;

  /// No description provided for @login_button.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrar'**
  String get login_button;

  /// No description provided for @login_forgot_password.
  ///
  /// In pt_BR, this message translates to:
  /// **'Esqueceu sua senha?'**
  String get login_forgot_password;

  /// No description provided for @login_error_invalid_credentials.
  ///
  /// In pt_BR, this message translates to:
  /// **'CPF ou senha inválidos'**
  String get login_error_invalid_credentials;

  /// No description provided for @login_error_empty_cpf.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite seu CPF'**
  String get login_error_empty_cpf;

  /// No description provided for @login_error_empty_password.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite sua senha'**
  String get login_error_empty_password;

  /// No description provided for @login_error_invalid_cpf.
  ///
  /// In pt_BR, this message translates to:
  /// **'CPF inválido'**
  String get login_error_invalid_cpf;

  /// No description provided for @features_carousel_pos_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ponto de Venda'**
  String get features_carousel_pos_title;

  /// No description provided for @features_carousel_pos_description.
  ///
  /// In pt_BR, this message translates to:
  /// **'Venda de ingressos e produtos de forma rápida e intuitiva'**
  String get features_carousel_pos_description;

  /// No description provided for @features_carousel_sessions_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gestão de Sessões'**
  String get features_carousel_sessions_title;

  /// No description provided for @features_carousel_sessions_description.
  ///
  /// In pt_BR, this message translates to:
  /// **'Controle completo de sessões e salas de cinema'**
  String get features_carousel_sessions_description;

  /// No description provided for @features_carousel_inventory_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Controle de Estoque'**
  String get features_carousel_inventory_title;

  /// No description provided for @features_carousel_inventory_description.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gerenciamento eficiente de produtos e suprimentos'**
  String get features_carousel_inventory_description;

  /// No description provided for @features_carousel_reports_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Relatórios e Análises'**
  String get features_carousel_reports_title;

  /// No description provided for @features_carousel_reports_description.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dados em tempo real para melhor tomada de decisão'**
  String get features_carousel_reports_description;

  /// No description provided for @splash_loading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carregando...'**
  String get splash_loading;

  /// No description provided for @dashboard_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dashboard'**
  String get dashboard_title;

  /// Dashboard greeting message
  ///
  /// In pt_BR, this message translates to:
  /// **'Olá, {name}!'**
  String dashboard_greeting(String name);

  /// No description provided for @dashboard_sales_today.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vendas Hoje'**
  String get dashboard_sales_today;

  /// No description provided for @dashboard_tickets_sold.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ingressos Vendidos'**
  String get dashboard_tickets_sold;

  /// No description provided for @dashboard_sessions_active.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sessões Ativas'**
  String get dashboard_sessions_active;

  /// No description provided for @dashboard_occupancy_rate.
  ///
  /// In pt_BR, this message translates to:
  /// **'Taxa de Ocupação'**
  String get dashboard_occupancy_rate;

  /// No description provided for @pos_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ponto de Venda'**
  String get pos_title;

  /// No description provided for @pos_select_session.
  ///
  /// In pt_BR, this message translates to:
  /// **'Selecionar Sessão'**
  String get pos_select_session;

  /// No description provided for @pos_select_products.
  ///
  /// In pt_BR, this message translates to:
  /// **'Adicionar Produtos'**
  String get pos_select_products;

  /// No description provided for @pos_cart_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carrinho'**
  String get pos_cart_title;

  /// No description provided for @pos_cart_empty.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carrinho vazio'**
  String get pos_cart_empty;

  /// No description provided for @pos_total.
  ///
  /// In pt_BR, this message translates to:
  /// **'Total'**
  String get pos_total;

  /// No description provided for @pos_finalize_sale.
  ///
  /// In pt_BR, this message translates to:
  /// **'Finalizar Venda'**
  String get pos_finalize_sale;

  /// No description provided for @pos_payment_method.
  ///
  /// In pt_BR, this message translates to:
  /// **'Forma de Pagamento'**
  String get pos_payment_method;

  /// No description provided for @pos_payment_cash.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dinheiro'**
  String get pos_payment_cash;

  /// No description provided for @pos_payment_card.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cartão'**
  String get pos_payment_card;

  /// No description provided for @pos_payment_pix.
  ///
  /// In pt_BR, this message translates to:
  /// **'PIX'**
  String get pos_payment_pix;

  /// No description provided for @pos_sale_success.
  ///
  /// In pt_BR, this message translates to:
  /// **'Venda realizada com sucesso!'**
  String get pos_sale_success;

  /// No description provided for @pos_sale_error.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao processar venda'**
  String get pos_sale_error;

  /// No description provided for @sessions_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sessões'**
  String get sessions_title;

  /// No description provided for @sessions_scheduled.
  ///
  /// In pt_BR, this message translates to:
  /// **'Agendada'**
  String get sessions_scheduled;

  /// No description provided for @sessions_in_progress.
  ///
  /// In pt_BR, this message translates to:
  /// **'Em Andamento'**
  String get sessions_in_progress;

  /// No description provided for @sessions_completed.
  ///
  /// In pt_BR, this message translates to:
  /// **'Finalizada'**
  String get sessions_completed;

  /// Room number label
  ///
  /// In pt_BR, this message translates to:
  /// **'Sala {number}'**
  String sessions_room(String number);

  /// No description provided for @sessions_occupancy.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ocupação'**
  String get sessions_occupancy;

  /// No description provided for @sessions_create.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nova Sessão'**
  String get sessions_create;

  /// No description provided for @sessions_edit.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar Sessão'**
  String get sessions_edit;

  /// No description provided for @sessions_delete_confirm.
  ///
  /// In pt_BR, this message translates to:
  /// **'Deseja realmente excluir esta sessão?'**
  String get sessions_delete_confirm;

  /// No description provided for @inventory_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Estoque'**
  String get inventory_title;

  /// No description provided for @inventory_products.
  ///
  /// In pt_BR, this message translates to:
  /// **'Produtos'**
  String get inventory_products;

  /// No description provided for @inventory_low_stock.
  ///
  /// In pt_BR, this message translates to:
  /// **'Estoque Baixo'**
  String get inventory_low_stock;

  /// No description provided for @inventory_out_of_stock.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fora de Estoque'**
  String get inventory_out_of_stock;

  /// No description provided for @inventory_add_product.
  ///
  /// In pt_BR, this message translates to:
  /// **'Adicionar Produto'**
  String get inventory_add_product;

  /// No description provided for @inventory_edit_product.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar Produto'**
  String get inventory_edit_product;

  /// No description provided for @inventory_product_name.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome do Produto'**
  String get inventory_product_name;

  /// No description provided for @inventory_product_quantity.
  ///
  /// In pt_BR, this message translates to:
  /// **'Quantidade'**
  String get inventory_product_quantity;

  /// No description provided for @inventory_product_price.
  ///
  /// In pt_BR, this message translates to:
  /// **'Preço'**
  String get inventory_product_price;

  /// No description provided for @inventory_product_category.
  ///
  /// In pt_BR, this message translates to:
  /// **'Categoria'**
  String get inventory_product_category;

  /// No description provided for @inventory_save_success.
  ///
  /// In pt_BR, this message translates to:
  /// **'Produto salvo com sucesso'**
  String get inventory_save_success;

  /// No description provided for @inventory_save_error.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao salvar produto'**
  String get inventory_save_error;

  /// No description provided for @reports_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Relatórios'**
  String get reports_title;

  /// No description provided for @reports_sales.
  ///
  /// In pt_BR, this message translates to:
  /// **'Vendas'**
  String get reports_sales;

  /// No description provided for @reports_sessions.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sessões'**
  String get reports_sessions;

  /// No description provided for @reports_inventory.
  ///
  /// In pt_BR, this message translates to:
  /// **'Estoque'**
  String get reports_inventory;

  /// No description provided for @reports_period.
  ///
  /// In pt_BR, this message translates to:
  /// **'Período'**
  String get reports_period;

  /// No description provided for @reports_today.
  ///
  /// In pt_BR, this message translates to:
  /// **'Hoje'**
  String get reports_today;

  /// No description provided for @reports_week.
  ///
  /// In pt_BR, this message translates to:
  /// **'Semana'**
  String get reports_week;

  /// No description provided for @reports_month.
  ///
  /// In pt_BR, this message translates to:
  /// **'Mês'**
  String get reports_month;

  /// No description provided for @reports_custom.
  ///
  /// In pt_BR, this message translates to:
  /// **'Personalizado'**
  String get reports_custom;

  /// No description provided for @reports_export.
  ///
  /// In pt_BR, this message translates to:
  /// **'Exportar'**
  String get reports_export;

  /// No description provided for @reports_generate.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gerar Relatório'**
  String get reports_generate;

  /// No description provided for @profile_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil'**
  String get profile_title;

  /// No description provided for @profile_name.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome'**
  String get profile_name;

  /// No description provided for @profile_cpf.
  ///
  /// In pt_BR, this message translates to:
  /// **'CPF'**
  String get profile_cpf;

  /// No description provided for @profile_role.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cargo'**
  String get profile_role;

  /// No description provided for @profile_cinema.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cinema'**
  String get profile_cinema;

  /// No description provided for @profile_change_password.
  ///
  /// In pt_BR, this message translates to:
  /// **'Alterar Senha'**
  String get profile_change_password;

  /// No description provided for @profile_logout.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sair'**
  String get profile_logout;

  /// No description provided for @profile_logout_confirm.
  ///
  /// In pt_BR, this message translates to:
  /// **'Deseja realmente sair?'**
  String get profile_logout_confirm;

  /// No description provided for @settings_title.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configurações'**
  String get settings_title;

  /// No description provided for @settings_general.
  ///
  /// In pt_BR, this message translates to:
  /// **'Geral'**
  String get settings_general;

  /// No description provided for @settings_notifications.
  ///
  /// In pt_BR, this message translates to:
  /// **'Notificações'**
  String get settings_notifications;

  /// No description provided for @settings_appearance.
  ///
  /// In pt_BR, this message translates to:
  /// **'Aparência'**
  String get settings_appearance;

  /// No description provided for @settings_language.
  ///
  /// In pt_BR, this message translates to:
  /// **'Idioma'**
  String get settings_language;

  /// No description provided for @settings_about.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sobre'**
  String get settings_about;

  /// No description provided for @error_network.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro de conexão. Verifique sua internet.'**
  String get error_network;

  /// No description provided for @error_server.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro no servidor. Tente novamente mais tarde.'**
  String get error_server;

  /// No description provided for @error_unknown.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro desconhecido. Tente novamente.'**
  String get error_unknown;

  /// No description provided for @error_timeout.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tempo limite excedido. Tente novamente.'**
  String get error_timeout;

  /// No description provided for @validation_required.
  ///
  /// In pt_BR, this message translates to:
  /// **'Campo obrigatório'**
  String get validation_required;

  /// No description provided for @validation_invalid_email.
  ///
  /// In pt_BR, this message translates to:
  /// **'E-mail inválido'**
  String get validation_invalid_email;

  /// No description provided for @validation_invalid_cpf.
  ///
  /// In pt_BR, this message translates to:
  /// **'CPF inválido'**
  String get validation_invalid_cpf;

  /// Minimum length validation message
  ///
  /// In pt_BR, this message translates to:
  /// **'Mínimo de {count} caracteres'**
  String validation_min_length(int count);

  /// Maximum length validation message
  ///
  /// In pt_BR, this message translates to:
  /// **'Máximo de {count} caracteres'**
  String validation_max_length(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
