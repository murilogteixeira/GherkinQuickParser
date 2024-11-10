
Feature: Extrato da conta

  Scenario: Consulta das transações
    Given usuário está na tela inicial
    When ele aperta no botão de extrato
    Then deve ver todas as trasações recentes
