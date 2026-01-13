import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import {
  provideHttpClient,
  withInterceptors,
  HttpInterceptorFn,
} from '@angular/common/http';
import { provideAuth0 } from '@auth0/auth0-angular';
import { inject } from '@angular/core';
import { AuthService as Auth0Service } from '@auth0/auth0-angular';
import { switchMap, take } from 'rxjs';

import { routes } from './app.routes';
import { environment } from '../environments/environment';

// HTTP Interceptor to attach Auth0 access token to API requests
const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth0 = inject(Auth0Service);

  // Only add token for API requests
  if (!req.url.startsWith(environment.apiBaseUrl)) {
    return next(req);
  }

  return auth0.getAccessTokenSilently().pipe(
    take(1),
    switchMap((token: string) => {
      const authReq = req.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`,
        },
      });
      return next(authReq);
    })
  );
};

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideAuth0({
      domain: environment.auth0.domain,
      clientId: environment.auth0.clientId,
      authorizationParams: {
        redirect_uri: environment.auth0.redirectUri,
        audience: environment.auth0.audience,
        scope: 'openid profile email',
      },
      // Enable token caching
      cacheLocation: 'localstorage',
      // Use refresh tokens for longer sessions
      useRefreshTokens: true,
    }),
  ],
};
