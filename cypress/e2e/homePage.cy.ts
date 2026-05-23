describe('The Home Page', () => {
  it('successfully loads', () => {
    cy.visit('/');
    cy.contains('Home');
    cy.contains('My Visits');
    cy.contains('About');
  });
});
