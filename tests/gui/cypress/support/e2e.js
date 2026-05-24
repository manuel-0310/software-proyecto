// Archivo de soporte global: comandos personalizados para pruebas Weddy

Cypress.Commands.add('loginWeddy', () => {
  return cy.request({
    method: 'POST',
    url: `${Cypress.env('apiUrl')}/auth/login`,
    body: { username: 'admin', password: 'weddy2024' },
  }).then((response) => {
    return response.body.access_token;
  });
});
