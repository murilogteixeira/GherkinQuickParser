//
//  ExtratoDaContaTests.swift
//
//  Created on 09/11/2024.
//

import Quick
import Nimble

class ExtratoDaContaTests: QuickSpec {

    override class func spec() {

        describe("Extrato Da Conta") {

            context("Consulta Das Transações") {
                it("Deve Ver Todas As Trasações Recentes") {
                    givenUsuárioEstáNaTelaInicial()
                    whenEleApertaNoBotãoDeExtrato()
                    thenDeveVerTodasAsTrasaçõesRecentes()
                }
            }

        }
    }
}
