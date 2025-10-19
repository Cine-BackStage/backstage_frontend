// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Backstage Cinema';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Salvar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_back => 'Voltar';

  @override
  String get common_next => 'Próximo';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_filter => 'Filtrar';

  @override
  String get common_loading => 'Carregando...';

  @override
  String get common_error => 'Erro';

  @override
  String get common_success => 'Sucesso';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get login_title => 'Bem-vindo ao Backstage';

  @override
  String get login_subtitle => 'Sistema de gerenciamento de cinema';

  @override
  String get login_cpf_label => 'CPF';

  @override
  String get login_cpf_hint => 'Digite seu CPF';

  @override
  String get login_password_label => 'Senha';

  @override
  String get login_password_hint => 'Digite sua senha';

  @override
  String get login_button => 'Entrar';

  @override
  String get login_forgot_password => 'Esqueceu sua senha?';

  @override
  String get login_error_invalid_credentials => 'CPF ou senha inválidos';

  @override
  String get login_error_empty_cpf => 'Por favor, digite seu CPF';

  @override
  String get login_error_empty_password => 'Por favor, digite sua senha';

  @override
  String get login_error_invalid_cpf => 'CPF inválido';

  @override
  String get features_carousel_pos_title => 'Ponto de Venda';

  @override
  String get features_carousel_pos_description =>
      'Venda de ingressos e produtos de forma rápida e intuitiva';

  @override
  String get features_carousel_sessions_title => 'Gestão de Sessões';

  @override
  String get features_carousel_sessions_description =>
      'Controle completo de sessões e salas de cinema';

  @override
  String get features_carousel_inventory_title => 'Controle de Estoque';

  @override
  String get features_carousel_inventory_description =>
      'Gerenciamento eficiente de produtos e suprimentos';

  @override
  String get features_carousel_reports_title => 'Relatórios e Análises';

  @override
  String get features_carousel_reports_description =>
      'Dados em tempo real para melhor tomada de decisão';

  @override
  String get splash_loading => 'Carregando...';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String dashboard_greeting(String name) {
    return 'Olá, $name!';
  }

  @override
  String get dashboard_sales_today => 'Vendas Hoje';

  @override
  String get dashboard_tickets_sold => 'Ingressos Vendidos';

  @override
  String get dashboard_sessions_active => 'Sessões Ativas';

  @override
  String get dashboard_occupancy_rate => 'Taxa de Ocupação';

  @override
  String get pos_title => 'Ponto de Venda';

  @override
  String get pos_select_session => 'Selecionar Sessão';

  @override
  String get pos_select_products => 'Adicionar Produtos';

  @override
  String get pos_cart_title => 'Carrinho';

  @override
  String get pos_cart_empty => 'Carrinho vazio';

  @override
  String get pos_total => 'Total';

  @override
  String get pos_finalize_sale => 'Finalizar Venda';

  @override
  String get pos_payment_method => 'Forma de Pagamento';

  @override
  String get pos_payment_cash => 'Dinheiro';

  @override
  String get pos_payment_card => 'Cartão';

  @override
  String get pos_payment_pix => 'PIX';

  @override
  String get pos_sale_success => 'Venda realizada com sucesso!';

  @override
  String get pos_sale_error => 'Erro ao processar venda';

  @override
  String get sessions_title => 'Sessões';

  @override
  String get sessions_scheduled => 'Agendada';

  @override
  String get sessions_in_progress => 'Em Andamento';

  @override
  String get sessions_completed => 'Finalizada';

  @override
  String sessions_room(String number) {
    return 'Sala $number';
  }

  @override
  String get sessions_occupancy => 'Ocupação';

  @override
  String get sessions_create => 'Nova Sessão';

  @override
  String get sessions_edit => 'Editar Sessão';

  @override
  String get sessions_delete_confirm => 'Deseja realmente excluir esta sessão?';

  @override
  String get inventory_title => 'Estoque';

  @override
  String get inventory_products => 'Produtos';

  @override
  String get inventory_low_stock => 'Estoque Baixo';

  @override
  String get inventory_out_of_stock => 'Fora de Estoque';

  @override
  String get inventory_add_product => 'Adicionar Produto';

  @override
  String get inventory_edit_product => 'Editar Produto';

  @override
  String get inventory_product_name => 'Nome do Produto';

  @override
  String get inventory_product_quantity => 'Quantidade';

  @override
  String get inventory_product_price => 'Preço';

  @override
  String get inventory_product_category => 'Categoria';

  @override
  String get inventory_save_success => 'Produto salvo com sucesso';

  @override
  String get inventory_save_error => 'Erro ao salvar produto';

  @override
  String get reports_title => 'Relatórios';

  @override
  String get reports_sales => 'Vendas';

  @override
  String get reports_sessions => 'Sessões';

  @override
  String get reports_inventory => 'Estoque';

  @override
  String get reports_period => 'Período';

  @override
  String get reports_today => 'Hoje';

  @override
  String get reports_week => 'Semana';

  @override
  String get reports_month => 'Mês';

  @override
  String get reports_custom => 'Personalizado';

  @override
  String get reports_export => 'Exportar';

  @override
  String get reports_generate => 'Gerar Relatório';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_name => 'Nome';

  @override
  String get profile_cpf => 'CPF';

  @override
  String get profile_role => 'Cargo';

  @override
  String get profile_cinema => 'Cinema';

  @override
  String get profile_change_password => 'Alterar Senha';

  @override
  String get profile_logout => 'Sair';

  @override
  String get profile_logout_confirm => 'Deseja realmente sair?';

  @override
  String get settings_title => 'Configurações';

  @override
  String get settings_general => 'Geral';

  @override
  String get settings_notifications => 'Notificações';

  @override
  String get settings_appearance => 'Aparência';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_about => 'Sobre';

  @override
  String get error_network => 'Erro de conexão. Verifique sua internet.';

  @override
  String get error_server => 'Erro no servidor. Tente novamente mais tarde.';

  @override
  String get error_unknown => 'Erro desconhecido. Tente novamente.';

  @override
  String get error_timeout => 'Tempo limite excedido. Tente novamente.';

  @override
  String get validation_required => 'Campo obrigatório';

  @override
  String get validation_invalid_email => 'E-mail inválido';

  @override
  String get validation_invalid_cpf => 'CPF inválido';

  @override
  String validation_min_length(int count) {
    return 'Mínimo de $count caracteres';
  }

  @override
  String validation_max_length(int count) {
    return 'Máximo de $count caracteres';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Backstage Cinema';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Salvar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_back => 'Voltar';

  @override
  String get common_next => 'Próximo';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_filter => 'Filtrar';

  @override
  String get common_loading => 'Carregando...';

  @override
  String get common_error => 'Erro';

  @override
  String get common_success => 'Sucesso';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get login_title => 'Bem-vindo ao Backstage';

  @override
  String get login_subtitle => 'Sistema de gerenciamento de cinema';

  @override
  String get login_cpf_label => 'CPF';

  @override
  String get login_cpf_hint => 'Digite seu CPF';

  @override
  String get login_password_label => 'Senha';

  @override
  String get login_password_hint => 'Digite sua senha';

  @override
  String get login_button => 'Entrar';

  @override
  String get login_forgot_password => 'Esqueceu sua senha?';

  @override
  String get login_error_invalid_credentials => 'CPF ou senha inválidos';

  @override
  String get login_error_empty_cpf => 'Por favor, digite seu CPF';

  @override
  String get login_error_empty_password => 'Por favor, digite sua senha';

  @override
  String get login_error_invalid_cpf => 'CPF inválido';

  @override
  String get features_carousel_pos_title => 'Ponto de Venda';

  @override
  String get features_carousel_pos_description =>
      'Venda de ingressos e produtos de forma rápida e intuitiva';

  @override
  String get features_carousel_sessions_title => 'Gestão de Sessões';

  @override
  String get features_carousel_sessions_description =>
      'Controle completo de sessões e salas de cinema';

  @override
  String get features_carousel_inventory_title => 'Controle de Estoque';

  @override
  String get features_carousel_inventory_description =>
      'Gerenciamento eficiente de produtos e suprimentos';

  @override
  String get features_carousel_reports_title => 'Relatórios e Análises';

  @override
  String get features_carousel_reports_description =>
      'Dados em tempo real para melhor tomada de decisão';

  @override
  String get splash_loading => 'Carregando...';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String dashboard_greeting(String name) {
    return 'Olá, $name!';
  }

  @override
  String get dashboard_sales_today => 'Vendas Hoje';

  @override
  String get dashboard_tickets_sold => 'Ingressos Vendidos';

  @override
  String get dashboard_sessions_active => 'Sessões Ativas';

  @override
  String get dashboard_occupancy_rate => 'Taxa de Ocupação';

  @override
  String get pos_title => 'Ponto de Venda';

  @override
  String get pos_select_session => 'Selecionar Sessão';

  @override
  String get pos_select_products => 'Adicionar Produtos';

  @override
  String get pos_cart_title => 'Carrinho';

  @override
  String get pos_cart_empty => 'Carrinho vazio';

  @override
  String get pos_total => 'Total';

  @override
  String get pos_finalize_sale => 'Finalizar Venda';

  @override
  String get pos_payment_method => 'Forma de Pagamento';

  @override
  String get pos_payment_cash => 'Dinheiro';

  @override
  String get pos_payment_card => 'Cartão';

  @override
  String get pos_payment_pix => 'PIX';

  @override
  String get pos_sale_success => 'Venda realizada com sucesso!';

  @override
  String get pos_sale_error => 'Erro ao processar venda';

  @override
  String get sessions_title => 'Sessões';

  @override
  String get sessions_scheduled => 'Agendada';

  @override
  String get sessions_in_progress => 'Em Andamento';

  @override
  String get sessions_completed => 'Finalizada';

  @override
  String sessions_room(String number) {
    return 'Sala $number';
  }

  @override
  String get sessions_occupancy => 'Ocupação';

  @override
  String get sessions_create => 'Nova Sessão';

  @override
  String get sessions_edit => 'Editar Sessão';

  @override
  String get sessions_delete_confirm => 'Deseja realmente excluir esta sessão?';

  @override
  String get inventory_title => 'Estoque';

  @override
  String get inventory_products => 'Produtos';

  @override
  String get inventory_low_stock => 'Estoque Baixo';

  @override
  String get inventory_out_of_stock => 'Fora de Estoque';

  @override
  String get inventory_add_product => 'Adicionar Produto';

  @override
  String get inventory_edit_product => 'Editar Produto';

  @override
  String get inventory_product_name => 'Nome do Produto';

  @override
  String get inventory_product_quantity => 'Quantidade';

  @override
  String get inventory_product_price => 'Preço';

  @override
  String get inventory_product_category => 'Categoria';

  @override
  String get inventory_save_success => 'Produto salvo com sucesso';

  @override
  String get inventory_save_error => 'Erro ao salvar produto';

  @override
  String get reports_title => 'Relatórios';

  @override
  String get reports_sales => 'Vendas';

  @override
  String get reports_sessions => 'Sessões';

  @override
  String get reports_inventory => 'Estoque';

  @override
  String get reports_period => 'Período';

  @override
  String get reports_today => 'Hoje';

  @override
  String get reports_week => 'Semana';

  @override
  String get reports_month => 'Mês';

  @override
  String get reports_custom => 'Personalizado';

  @override
  String get reports_export => 'Exportar';

  @override
  String get reports_generate => 'Gerar Relatório';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_name => 'Nome';

  @override
  String get profile_cpf => 'CPF';

  @override
  String get profile_role => 'Cargo';

  @override
  String get profile_cinema => 'Cinema';

  @override
  String get profile_change_password => 'Alterar Senha';

  @override
  String get profile_logout => 'Sair';

  @override
  String get profile_logout_confirm => 'Deseja realmente sair?';

  @override
  String get settings_title => 'Configurações';

  @override
  String get settings_general => 'Geral';

  @override
  String get settings_notifications => 'Notificações';

  @override
  String get settings_appearance => 'Aparência';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_about => 'Sobre';

  @override
  String get error_network => 'Erro de conexão. Verifique sua internet.';

  @override
  String get error_server => 'Erro no servidor. Tente novamente mais tarde.';

  @override
  String get error_unknown => 'Erro desconhecido. Tente novamente.';

  @override
  String get error_timeout => 'Tempo limite excedido. Tente novamente.';

  @override
  String get validation_required => 'Campo obrigatório';

  @override
  String get validation_invalid_email => 'E-mail inválido';

  @override
  String get validation_invalid_cpf => 'CPF inválido';

  @override
  String validation_min_length(int count) {
    return 'Mínimo de $count caracteres';
  }

  @override
  String validation_max_length(int count) {
    return 'Máximo de $count caracteres';
  }
}
