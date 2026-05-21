describe('The Logged-in Home Page', () => {
  it('successfully loads', () => {
    cy.fakeUserLogin();

    cy.visit('/');
    cy.contains('My Visits');
  });
});
