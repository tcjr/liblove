describe('The Home Page', () => {
  it('successfully loads', () => {
    cy.visit('/');

    // ensure we're logged out
    cy.get('body').should('not.contain', 'My Visits');
  });
});
