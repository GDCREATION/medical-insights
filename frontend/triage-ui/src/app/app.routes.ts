import { Routes } from '@angular/router';
import { LandingComponent } from './components/landing/landing.component';
import { ConsentComponent } from './components/consent/consent.component';
import { PatientTriageComponent } from './components/patient-triage/patient-triage.component';
import { ClinicianDashboardComponent } from './components/clinician-dashboard/clinician-dashboard.component';
import { NotAuthorizedComponent } from './components/not-authorized/not-authorized.component';
import { roleGuard } from './guards/role.guard';
import { consentGuard } from './guards/consent.guard';

export const routes: Routes = [
  { path: '', component: LandingComponent },
  {
    path: 'consent',
    component: ConsentComponent,
    canMatch: [roleGuard(['patient'])],
  },
  {
    path: 'patient/triage',
    component: PatientTriageComponent,
    canMatch: [roleGuard(['patient']), consentGuard],
  },
  {
    path: 'clinician/review',
    component: ClinicianDashboardComponent,
    canMatch: [roleGuard(['clinician'])],
  },
  { path: 'not-authorized', component: NotAuthorizedComponent },
  { path: '**', redirectTo: '' },
];
