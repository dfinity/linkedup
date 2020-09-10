const canisters = JSON.parse(Cypress.env('CANISTER_IDS'));

describe('linkedup e2e', () => {
  it('loads linkedup canister', function () {
    cy.on('uncaught:exception', (err, runnable) => {
      expect(err.message).to.include(`Cannot set property 'getPropertyValue' of undefined`);

      // using mocha's async done callback to finish
      // this test so we prove that an uncaught exception
      // was thrown

      // return false to prevent the error from
      // failing this test
      return false;
    });
    cy.visit({
      url: '/',
      qs: {
        canisterId: canisters['linkedup_assets'],
      },
    });
    cy.get('a#login').click();
    cy.get('h4.lu_section-header').should('contain.text', 'Profile').and('be.visible');
  });
});
