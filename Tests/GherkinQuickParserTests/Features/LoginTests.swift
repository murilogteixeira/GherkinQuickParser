//
//  LoginDeUsuárioTests.swift
//
//  Created on 09/11/2024.
//

import Quick
import Nimble

class LoginDeUsuárioTests: QuickSpec {

    override class func spec() {

        describe("Login De Usuário") {

            context("Login Com Sucesso") {
                it("Deve Ver A Tela Inicial") {
                    givenUsuárioEstáNaTelaDeLogin()
                    whenEleInsereUmEmailVálido()
                    thenDeveVerATelaInicial()
                }
            }

            context("Login Com Falha") {
                it("Deve Ver Uma Mensagem De Erro") {
                    givenUsuárioEstáNaTelaDeLogin()
                    whenEleInsereUmEmailInválido()
                    thenDeveVerUmaMensagemDeErro()
                }
            }

        }
    }
}
