const canisters = JSON.parse(Cypress.env('CANISTER_IDS'));

describe('linkedup e2e', () => {
  it('loads linkedup canister', function () {
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
