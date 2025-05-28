import { Component, EventEmitter, Input, OnChanges, OnInit, Output, SimpleChanges, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { 
  BodTableModule, 
  BodTableComponent, 
  BodTableMetadata, 
  BodPageContainerModule,
  NotificationMessage,
  RowLeftAction,
  ColumnType,
  SelectPageMode 
} from '@bod/common';
import { CurrencyTableSingle } from '../add-edit-conditions/add-edit-conditions.model';
import { ConditionDetailService } from '../condition-detail.service';
import { MatTableDataSource } from '@angular/material/table';
import { FormBuilder, FormGroup, ReactiveFormsModule, FormsModule } from '@angular/forms';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';

@Component({
  selector: 'bod-currency-condition',
  standalone: true,
  imports: [
    CommonModule,
    BodTableModule,
    BodPageContainerModule,
    MatSlideToggleModule,
    ReactiveFormsModule,
    FormsModule
  ],
  templateUrl: './currency-condition.component.html',
  styleUrl: './currency-condition.component.scss'
})
export class CurrencyConditionComponent implements OnInit, OnChanges {
  @Input() currencyDataSingleSelect: BodTableMetadata;
  @Input() selectedRowSingleSelect: CurrencyTableSingle[] = [];
  @Output() rowSelected = new EventEmitter<CurrencyTableSingle[]>();
  @Output() defaultChanged = new EventEmitter<{ rowIndex: number, isDefault: boolean }>();
  
  @ViewChild('currencyConditionsForCurr', { static: false })
  currencyTable: BodTableComponent;

  ngAfterViewInit(): void {
    setTimeout(() => this.selectCurrencyRows(),0);
  }
  
  
  
  ngOnChanges(changes: SimpleChanges): void {
    if (changes['selectedRowSingleSelect'] && this.selectedRowSingleSelect?.length) {
      console.log('📥 selectedRowSingleSelect changed:', this.selectedRowSingleSelect);
  
      // Wait for table to render rows
      setTimeout(() => {
        this.selectCurrencyRows();
      }, 0);
    }
  }
  
  private selectCurrencyRows(): void {
    const tableData = this.currencyDataSingleSelect?.datasource?.data || [];
    const selection = this.currencyTable?.selection;
  
    // if (!selection || tableData.length === 0) {
    //   console.warn('⚠️ Table or selection model not ready');
    //   return;
    // }
  
    console.log('📌 Table data (for selection):', tableData);
    console.log('📌 Incoming selected rows:', this.selectedRowSingleSelect);
  
    tableData.forEach(dataRow => {
      const match = this.selectedRowSingleSelect.find(
        sel => sel.identifier === dataRow.identifier
      );
      if (match) {
        selection.select(dataRow);
      }
    });
  }
  public allowRowSelection = true;
  public rowSelectionStrategy: SelectPageMode = SelectPageMode.ALL_PAGES;
  public showEdit = true;
  public defaultForm: FormGroup;
  
  constructor(
    private conditionDetailService: ConditionDetailService,
    private fb: FormBuilder
  ) {}
  
  ngOnInit() { 
    this.defaultForm = this.fb.group({});
    
    // Initialize the table if not provided by parent
    if (!this.currencyDataSingleSelect) {
      this.initializeTable();
    }
  }
  
  private initializeTable() {
    this.currencyDataSingleSelect = {
      title: 'Currency Condition',
      columns: [...this.conditionDetailService.currency],
      rowLeftAction: RowLeftAction.multipleRowSelection,
      enablePagination: true,
      datasource: new MatTableDataSource<CurrencyTableSingle>([]),
      noRecordsMessage: 'No Currency defined'
    };
    
    // Load data if needed
    this.loadCurrencyData();
  }
  
  private loadCurrencyData() {
    this.conditionDetailService.getCurrency().subscribe((response: any[]) => {
      const currencyData = response.map((item: any, index: number) => ({
        index: index,
        identifier: item.identifier,
        code: item.code,
        currencyISO4217Val: item.currencyISO4217Val,
        default: false // Add default property initialized to false
      }));
      
      this.currencyDataSingleSelect.datasource.data = currencyData;
    });
  }
  
  public rowSelectionSingleSelect(element: CurrencyTableSingle[]) {
    this.selectedRowSingleSelect = element;
    this.rowSelected.emit(this.selectedRowSingleSelect);
  }
  
  public onDefaultToggleChange(event: any, rowIndex: number) {
    // Get current data and the row being toggled
    const data = [...this.currencyDataSingleSelect.datasource.data];
    const row = data.find(r => r.index === rowIndex);
    
    if (!row) return;
    
    // Update default status
    if (event.checked) {
      // If this row is now default, unmark all others
      data.forEach(item => {
        item.default = item.index === rowIndex;
      });
    } else {
      // Just update this row's default status
      row.default = false;
    }
    
    // Update the data source
    this.currencyDataSingleSelect.datasource.data = data;
    
    // Emit the change
    this.defaultChanged.emit({
      rowIndex: rowIndex,
      isDefault: event.checked
    });
  }
  
}
