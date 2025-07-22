<bod-message-container [messages]="errorMessages"></bod-message-container>
<bod-form
  [formGroup]="addNewCounterFormGroup"
  rufId
  [type]="formType"
  (onSubmit)="onAddNewCounter(isAdd)"
  (onReset)="onReset(isAdd)"
  fisStyle
>
  <bod-input-layout col="2">
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.code'"
      [forTextOnly]="true"
      [required]="true"
    >
    <div *ngIf="isEdit">
      {{ addNewCounterFormGroup.get('counterCode')?.value }}
    </div>
      <mat-form-field appearance="outline" fisStyle *ngIf="!isEdit">
        <input
          type="text"
          matInput
          fisStyle
          formControlName="counterCode"
          name="counterCode"
        />
        
        <mat-error>
         {{ getError('counterCode', addNewCounterFormGroup) | translate }}
        </mat-error> 
        <mat-error *ngIf="addNewCounterFormGroup.get('counterCode').hasError('noSpecialCharacters')">
        </mat-error>
      </mat-form-field>
    </bod-control-group>
   
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.name'"
      [forTextOnly]="true"
      [required]="true"
    >
      <mat-form-field appearance="outline" fisStyle>
        <input
          type="text"
          matInput
          fisStyle
          formControlName="counterName"
          name="counterName"
        />
        <mat-error>
          {{ getError('counterName', addNewCounterFormGroup) | translate }}
        </mat-error>
      </mat-form-field>
    </bod-control-group>
  </bod-input-layout>
  
  <bod-input-layout col="2">
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.classificationtype'"
      [forTextOnly]="true"
      [required]="true"
    >
      <mat-form-field appearance="outline" fisStyle>
        <mat-select
          panelClass="fis-style"
          formControlName="classificationtype"
          name="classificationtype"
        >
          <mat-option
            *ngFor="let classificationtype of classificationtypes"
            [value]="classificationtype.value"
          >
            {{ classificationtype.label }}
          </mat-option>
        </mat-select>
      </mat-form-field>
    </bod-control-group>
  </bod-input-layout>
<h1>Product Type Relationship</h1>
<bod-input-layout col="1">
    <bod-control-group
      [truncate]="false"
      [label]="translationKey + 'metadataconfig.rulecheck'"
      [forTextOnly]="true"
      [required]="false"
    >
      <mat-slide-toggle
        fisStyle
        color="primary"
        formControlName="rulecheck"
        name="rulecheck"
      >
      </mat-slide-toggle>
    </bod-control-group>
  </bod-input-layout>

   <!-- Period Type Section -->
  <bod-period-type
    #periodTypeRef
    [periodTypeData]="periodTypeTableData"
    (completeDeltaChangePeriodType)="handleCompleteDeltaChangePeriodType($event)"
    (tableDirty)="onTableDirty()"
  ></bod-period-type>

</bod-form>









import {
  ChangeDetectorRef,
  Component,
  EventEmitter,
  Input,
  OnInit,
  Output,
  ViewChild
} from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  AbstractControl,
  FormBuilder,
  FormControl,
  FormGroup,
  FormsModule,
  ReactiveFormsModule,
  UntypedFormControl,
  UntypedFormGroup,
  ValidationErrors,
  ValidatorFn,
  Validators
} from '@angular/forms';
import { TranslationKey } from '../../metadat-config/codegen-config.constant';
import { CounterService } from '../counters-service';
import { MetadataService } from '../../metadat-config/metada-config.service';
import {
  BodCommonDialogService,
  BodCommonModule,
  BodCurrencyControlModule,
  BodDynamicFormModule,
  BodFormModule,
  BodFormStateService,
  BodFormTypes,
  BodPageContainerModule,
  BodTableAction,
  BodTableActionsModule,
  BodTableActionType,
  BodTableComponent,
  BodTableMetadata,
  BodTableModule,
  CommonDialogComponent,
  ControlGroupModule,
  DirectivesModule,
  EditTableAction,
  EditTableEventData,
  InlineEditOutput,
  InputLayoutModule,
  InquiryLayoutModule,
  MessageContainerModule,
  ModeOptions,
  NotificationMessage,
  NotificationMessageType,
  RowLeftAction,
  SearchFieldModule,
  SectionContainerModule
} from '@bod/common';
import { CounterComponent } from '../counters.component';
import { MatIconModule } from '@angular/material/icon';
import { RufIconModule } from '@ruf/shell/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatTabsModule } from '@angular/material/tabs';
import { TranslateModule } from '@ngx-translate/core';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatTableDataSource } from '@angular/material/table';
import { FormUtilityService } from '../../metadat-config/form-utility.service';
import { MatDialogRef } from '@angular/material/dialog';
import { CounterList } from './add-edit-counters.mode';
import { PeriodTypeComponent, PeriodType } from './period-type/period-type.component';

@Component({
  selector: 'bod-add-edit-counter',
  standalone: true,
  imports: [
    CounterComponent,
    PeriodTypeComponent,
    InquiryLayoutModule,
    SearchFieldModule,
    MatIconModule,
    RufIconModule,
    DirectivesModule,
    MatButtonModule,
    MatSlideToggleModule,
    MatTabsModule,
    CommonModule,
    TranslateModule,
    BodPageContainerModule,
    BodTableModule,
    TranslateModule,
    BodTableActionsModule,
    FormsModule,
    InputLayoutModule,
    BodFormModule,
    ControlGroupModule,
    MatFormFieldModule,
    MatSelectModule,
    MatDatepickerModule,
    ReactiveFormsModule,
    BodDynamicFormModule,
    SectionContainerModule,
    MatInputModule,
    TranslateModule,
    MessageContainerModule,
    MatButtonToggleModule,
    BodCurrencyControlModule,
    MatDatepickerModule,
    BodCommonModule
  ],
  templateUrl: './add-edit-counters.component.html',
  styleUrl: './add-edit-counters.component.scss'
})
export class AddEditCounterComponent implements OnInit {
  public translationKey = TranslationKey;
  public addNewCounterFormGroup: UntypedFormGroup;
  formType: BodFormTypes = BodFormTypes.SUBMIT;

  @Input() retainedCode: string = '';
  @Input() retainedIdentifier: number = 0;
  @Input() retainedName: string = '';
  @Input() retainedSystemBalance: boolean = false;
  @Input() retainedClassificationType: string = '';
  @Input() retainedRuleCheck: boolean = false;
  @Input() retainedPeriodTypeData: PeriodType[] = [];
  @Input() editCounterRow: CounterList;
  
  @Output() apiResponse: EventEmitter<NotificationMessage[]> = new EventEmitter<
    NotificationMessage[]
  >();
  
  public errorMessages: NotificationMessage[] = [];
  public modeOptions: ModeOptions = { input: false, reset: false };
  
  @ViewChild('systemMessage', { static: true }) systemMessage: any;
  @ViewChild('periodTypeRef') periodTypeRef: PeriodTypeComponent;
  
  public messages: NotificationMessage[] = [];
  public message: NotificationMessage | undefined;
  private dialogRef$: MatDialogRef<CommonDialogComponent, any>;

  classificationtypes = [
    { label: 'PostingCounter', value: 'PostingCounter' },
    { label: 'ManualBumpUpCounter', value: 'ManualBumpUpCounter' },
    { label: 'OverdraftCounter', value: 'OverdraftCounter' },
    { label: 'ArrangementCounter', value: 'ArrangementCounter' }
  ];
  
  statusControl = new FormControl(null); 
  public previousStatus: string | undefined;
  isAdd = true;
  isEdit = false;
  public isTableDirty = false;

  // Period Type table data
  public periodTypeTableData: PeriodType[] = [];

  constructor(
    private changeDetectorRef: ChangeDetectorRef,
    private bodFormStateService: BodFormStateService,
    public counterService: CounterService,
    private fb: FormBuilder,
    private bodCommonDialogService: BodCommonDialogService,
    private metadataService: MetadataService
  ) {}

  ngOnInit() {
    this.initForm();
    
    if (this.editCounterRow) {
      this.counterForm(this.editCounterRow);
    }

    this.metadataService.retrieveAll().subscribe((response: any) => {
      const firstStatus = response?.data?.[0]?.MetadataStatus;
      const statusToSet = firstStatus || 'NEW';
      this.statusControl.setValue(statusToSet);
      this.previousStatus = statusToSet;
    });
  }

  private initForm(): void {
    this.addNewCounterFormGroup = this.fb.group({
      counterCode: new UntypedFormControl('', [
        Validators.required,
        this.noSpecialCharactersValidator(),
        this.maxLengthValidator(32)
      ]),
      counterIdentifier: [{ value: '', disabled: true }],
      counterName: new UntypedFormControl('', [
        Validators.required,
        this.maxLengthValidator(120)
      ]),
      classificationtype: new UntypedFormControl('', [Validators.required]),
      rulecheck: new UntypedFormControl(false)
    });
  }

  noSpecialCharactersValidator(): ValidatorFn {
    return (control: AbstractControl): { [key: string]: any } | null => {
      const forbidden = /[^a-zA-Z0-9]/.test(control.value);
      return forbidden
        ? { noSpecialCharacters: { value: control.value } }
        : null;
    };
  }

  maxLengthValidator(maxLength: number): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value;

      if (value === null || value === undefined || value === '') {
        return null;
      }

      const stringValue = value.toString();

      return stringValue.length > maxLength
        ? { maxLength: 'Value exceeds allowed digit limit' }
        : null;
    };
  }

  identifierSearch(field: string): Promise<void> {
    return new Promise((resolve, reject) => {
      this.metadataService.idfrSearch().subscribe(
        (response: string) => {
          if (field === 'counterIdentifier') {
            this.addNewCounterFormGroup.controls['counterIdentifier'].setValue(response);
          }
          this.addNewCounterFormGroup.markAsDirty();
          resolve();
        },
        error => {
          console.error('Error:', error);
          reject(error);
        }
      );
    });
  }

  public getError(control: string, formGroup: UntypedFormGroup): string {
    if (formGroup) {
      const fc: AbstractControl = formGroup.get(control);
      if (fc && fc.errors && fc.touched) {
        return FormUtilityService.getCommonFCErrorMsg(fc);
      }
    }
  }

  public onTableDirty(): void {
    this.isTableDirty = true;
    this.addNewCounterFormGroup.markAsDirty();
  }

  // Handle period type table data changes
  public completeDeltaPeriodTypeData: any;
  handleCompleteDeltaChangePeriodType(data: any) {
    this.completeDeltaPeriodTypeData = data;
    console.log('Received CompleteDelta from period type child:', this.completeDeltaPeriodTypeData);
  }

  onAddNewCounter(isAdd: boolean) {
    const promises = [];

    if (isAdd) {
      promises.push(this.identifierSearch('counterIdentifier'));
    }

    Promise.all(promises)
      .then(() => {
        this.submitForm(isAdd);
      })
      .catch(error => {
        console.error('Error during identifier search:', error);
      });
  }

submitForm(isAdd: boolean) {
  this.errorMessages = [];

  if (this.addNewCounterFormGroup.invalid) {
    this.addNewCounterFormGroup.markAllAsTouched();
    const missingFields = this.getInvalidRequiredFields(this.addNewCounterFormGroup);
    this.handleError(
      {
        errorCode: 'FORM_INVALID',
        status: 400,
        missingFields
      },
      isAdd
    );
    return;
  }

  const formValue = this.addNewCounterFormGroup.getRawValue();
  this.addNewCounterFormGroup.controls['counterIdentifier'].enable();

  // Get product type data from metadata service
  const productTypeKeys = this.metadataService.getProductTypeKeys();
  const productTypeValues = this.metadataService.getProductTypeValues();

  // Get period type data
  const periodTypeList = this.periodTypeRef?.getCurrentTablePeriodType() || [];
  // Set to null if empty
  const productElementCounterTypePeriodList = periodTypeList.length === 0 ? null : periodTypeList.map(period => ({
    productTypeIdentifier: productTypeValues[0], // or map for each product type if needed
    counterIdentifier: formValue.counterIdentifier,
    periodType: period.periodType,
    isCalculate: period.isCalculated ? 'Y' : 'N'
  }));

  // Build the new structure
  const counterDetailList = [{
    counterType: {
      identifier: formValue.counterIdentifier,
      code: formValue.counterCode,
      name: formValue.counterName,
      classificationType: formValue.classificationtype
    },
    productElementCounterTypeRltnpList: productTypeKeys.map((code, index) => ({
      productTypeIdentifier: productTypeValues[index],
      counterIdentifier: formValue.counterIdentifier,
      counterCode: formValue.counterCode,
      ruleCheck: formValue.rulecheck ? 'Y' : 'N'
    })),
    productElementCounterTypePeriodList // <-- use null if empty
  }];

  const counterData = {
    metadataType: 'Counter',
    counterDetailList,
    productTypeList: productTypeKeys.map((code, index) => ({
      identifier: productTypeValues[index],
      code: code
    }))
  };

  console.log('Counter data to be sent:', JSON.stringify(counterData, null, 2));

  const serviceCall = isAdd
    ? this.counterService.saveCounter(counterData)
    : this.counterService.updateCounter(counterData);

  serviceCall.subscribe({
    next: resp => this.successResponse(resp, counterData, isAdd),
    error: (err: NotificationMessage[]) => this.handleError(err, isAdd)
  });

  this.addNewCounterFormGroup.controls['counterIdentifier'].disable();
}


  private getInvalidRequiredFields(formGroup: FormGroup): string[] {
    const invalidFields: string[] = [];

    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      if (control && control.errors?.['required']) {
        invalidFields.push(key);
      }
    });

    return invalidFields;
  }

  private successResponse(resp, counterData, isAdd) {
    const counterCode = counterData.counterDetailList
[0].counterType.code;
    const SuccessMsg = isAdd
      ? `${counterCode} Added successfully`
      : `${counterCode} Updated successfully`;
    this.apiResponse.emit({ ...counterData, SuccessMsg });
  }

  private handleError(error: any, isAdd: boolean) {
    let errorMsg = '';

    if (error.errorCode === 'FORM_INVALID' || error.status === 400) {
      if (error.missingFields?.length) {
        errorMsg = `Please fill the required fields.`;
      } else {
        errorMsg = 'Please fill the required fields.';
      }
    } else if (error.errorCode === 'PERIOD_TYPE_REQUIRED') {
      errorMsg = 'Period type is required for all rows.';
    } else if (error.errorCode === 'DUPLICATE_PERIOD_TYPE') {
      errorMsg = 'Duplicate period types found. Please ensure all period types are unique.';
    } else if (error.error?.errorCode === "MBP_SDK_BUS_ERR_005") {
      errorMsg = 'Code already exists.';
    } else if (error.error?.errorCode === "MBP_SDK_BUS_ERR_004") {
      errorMsg = error.error?.errorDescription || 'Code already exists.';
    } else {
      errorMsg = 'Unknown error occurred.';
    }

    this.message = {
      code: error.errorCode,
      text: errorMsg,
      type: NotificationMessageType.ERROR
    };
    this.errorMessages.push(this.message);

    // Auto-remove error messages after 10 seconds
    setTimeout(() => {
      this.errorMessages = this.errorMessages.filter(msg => msg.text !== errorMsg);
    }, 10000);
  }

  onReset(isAdd: boolean): void {
    const isEditMode = this.isEdit;
    
    // Reset error messages
    this.errorMessages = [];
    
    // Reset the form
    this.addNewCounterFormGroup.reset();
    this.addNewCounterFormGroup.markAsPristine();
    this.addNewCounterFormGroup.markAsUntouched();

    // Reset table dirty state
    this.isTableDirty = false;

    if (isEditMode) {
      // Restore retained values for edit mode
      this.addNewCounterFormGroup.get('counterCode')?.setValue(this.retainedCode);
      this.addNewCounterFormGroup.get('counterCode')?.disable();
      this.addNewCounterFormGroup.get('counterIdentifier')?.setValue(this.retainedIdentifier);
      this.addNewCounterFormGroup.get('counterIdentifier')?.disable();
      this.addNewCounterFormGroup.get('counterName')?.setValue(this.retainedName);
      this.addNewCounterFormGroup.get('classificationtype')?.setValue(this.retainedClassificationType);
      this.addNewCounterFormGroup.get('rulecheck')?.setValue(this.retainedRuleCheck);
      
      // Reset period type data to retained values
      this.periodTypeTableData = [...this.retainedPeriodTypeData];
      
      // Reset the period type table if it exists
      if (this.periodTypeRef) {
        this.periodTypeRef.reset();
      }
    } else {
      this.addNewCounterFormGroup.get('counterCode')?.enable();
      this.addNewCounterFormGroup.get('counterIdentifier')?.enable();
      
      // Clear period type data for new additions
      this.periodTypeTableData = [];
    }

    this.changeDetectorRef.detectChanges();
  }

  private counterForm(element: CounterList): void {
    this.isAdd = false;
    this.isEdit = true;

    // Store retained values
    this.retainedCode = element.code || '';
    this.retainedIdentifier = element.identifier || 0;
    this.retainedName = element.name || '';
    this.retainedClassificationType = element.classificationType || '';
    this.retainedRuleCheck = element.ruleCheck === 'Y';
    
    // Store period type data if it exists
    this.retainedPeriodTypeData = element.periodTypeList ? 
      element.periodTypeList.map((item, index) => ({
        id: index + 1,
        periodType: item.periodType,
        isCalculated: item.isCalculated
      })) : [];

    this.addNewCounterFormGroup.patchValue({
      counterIdentifier: element.identifier,
      counterCode: element.code,
      counterName: element.name,
      classificationtype: element.classificationType,
      rulecheck: element.ruleCheck === 'Y'
    });

    // Set period type data
    this.periodTypeTableData = [...this.retainedPeriodTypeData];

    // Disable code field in edit mode
    this.addNewCounterFormGroup.get('counterCode')?.disable();
  }
}










export interface CounterList {
  identifier?: number;
  code?: string;
  name?: string;
  classificationType?: string;
  ruleCheck?: string;
  counterInquiry?: CounterInquiry[];
  periodTypeList?: PeriodTypeItem[];
  sourceType?: 'ADD_EDIT' | 'EXISTING';
}

export interface CounterInquiry {
  id: number;
  label: string;
  value: string;
}

export interface PeriodTypeItem {
  periodType: string;
  isCalculated: boolean;
}

export interface CounterData {
  metadataType: string;
  counterList: CounterListItem[];
  productTypeList: ProductType[];
}

export interface CounterListItem {
  counter: Counter;
  periodTypeList?: PeriodTypeItem[];
}

export interface Counter {
  identifier: number;
  code: string;
  name: string;
  systemCounter?: string;
  classificationType: string;
  ruleCheck: string;
}

export interface ProductType {
  identifier: number;
  code: string;
}
