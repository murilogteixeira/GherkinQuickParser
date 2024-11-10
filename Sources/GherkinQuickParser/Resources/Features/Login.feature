
Feature: Login de usuário

  Scenario: Login com sucesso
    Given usuário está na tela de login
    When ele insere um email válido
    And ele insere uma senha válida
    Then deve ver a tela inicial

  Scenario: Login com falha
    Given usuário está na tela de login
    When ele insere um email inválido
    And insere uma senha inválida
    Then deve ver uma mensagem de erro
