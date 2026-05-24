// Pruebas de GUI — verifica que la interfaz Swagger /docs carga correctamente
describe('Weddy API — Interfaz Swagger UI', () => {

  it('La página /docs carga con status 200', () => {
    cy.request('/docs').its('status').should('eq', 200);
  });

  it('La página /docs contiene el título de la API', () => {
    cy.visit('/docs');
    cy.get('title').should('exist');
    cy.contains('Weddy API').should('exist');
  });

  it('/openapi.json retorna el esquema de la API', () => {
    cy.request('/openapi.json').then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('info');
      expect(response.body.info.title).to.eq('Weddy API');
      expect(response.body).to.have.property('paths');
    });
  });

  it('/openapi.json incluye los endpoints principales', () => {
    cy.request('/openapi.json').then((response) => {
      const paths = Object.keys(response.body.paths);
      expect(paths).to.include('/auth/login');
      expect(paths).to.include('/invitados/');
      expect(paths).to.include('/presupuesto/');
      expect(paths).to.include('/health');
    });
  });

});
