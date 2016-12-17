<riot-period-input>
  <input type="text" name={ opts.name } value={ opts.v } class="form-control" style="width: 140px;" />

  <script>
  this.picker = null;
  this.on('mount', function() {
    var self = this
    var input = this.root.querySelector('input')

    if('ontouchstart' in window) {
      // タップイベントがある場合にはinput[type=date]に
      input.type = 'date'
      $(input).on('blur', function(e) {
        //min,max値を参照して、必要に応じて訂正する
        var now = input.value
        if(moment(now).isBetween(input.min, input.max)) {
          self.opts.v = input.value
        } else {
          input.value = self.opts.v
        }
      })
    } else {
      // タップイベントが無い場合にはPikadayプラグインを使用
      this.picker = new Pikaday({
        field: input,
        format: 'YYYY/MM/DD',
        onSelect: function(date) {
          //min,max値を参照して、必要に応じて訂正する
          var now = input.value.replace(/\//g, "-")
          if(moment(date).isBetween(input.min, input.max)) {
            self.opts.v = now
            self.parent.setMinMax(self.parent)
          } else {
            input.value = self.opts.v.replace(/-/g, "/")
            self.picker.setDate(moment(self.opts.v).toDate())
          }
        }
      });
    }
  })

  this.on('update', function() {
    var input = this.root.querySelector('input')
    var hasTapEvent = ('ontouchstart' in window);
    if(!hasTapEvent) {
      input.value = input.value.replace(/-/g, "/")//表示文字列のformatを'YYYY/MM/DD'に再度訂正する
    }
  })
  </script>
</riot-period-input>

<riot-period-select>

  <div class="dropdown open">
    <button class="btn btn-secondary dropdown-toggle" type="button" id="riot-period-select" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      { display }
    </button>

    <div class="dropdown-menu pb-1" aria-labelledby="riot-period-select">
      <h6 class="dropdown-header">期間を選択</h6>
      <a class={dropdown-item: true, active: isActive(1, 'weeks')} href="#" onclick={ onselect } data-period="1" data-period-type="weeks">先週</a>
      <a class={dropdown-item: true, active: isActive(1, 'months')} href="#" onclick={ onselect } data-period="1" data-period-type="months">今月</a>
      <a class={dropdown-item: true, active: isActive(3, 'months')} href="#" onclick={ onselect } data-period="3" data-period-type="months">過去3ヶ月</a>
      <a class={dropdown-item: true, active: isActive(6, 'months')} href="#" onclick={ onselect } data-period="6" data-period-type="months">過去半年間</a>
      <a class={dropdown-item: true, active: isActive(1, 'years')} href="#" onclick={ onselect } data-period="1" data-period-type="years">過去1年</a>
      <div class="dropdown-divider"></div>
      <h6 class="dropdown-header">カスタム</h6>
      <div class="dropdown-item dropdown-item-from">
        <form onsubmit={ submit }>
          <riot-period-input name="from" v={ from.format('YYYY-MM-DD') }></riot-period-input>
          〜
          <riot-period-input name="to" v={ to.format('YYYY-MM-DD') }></riot-period-input>
          <button type="submit" class="btn btn-secondary">決定</button>
        </form>
      </div>
    </div>
  </div>

  <script>
  this.from = '';
  this.to = '';
  this.display = '';
  this.period = null;
  this.period_type = null;
  this.on('mount', function() {
    setPeriod(this, 1, 'months')//今月
  })

  //ボタンの状態
  isActive(period, type) {
    if(this.period == period && this.period_type == type) {
      return true
    } else {
      return false
    }
  }

  onselect(e) {
    e.preventDefault()
    var day = e.target.getAttribute('data-period')
    var type = e.target.getAttribute('data-period-type')
    setPeriod(this, day, type)
  }

  submit(e) {
    this.period = null;
    this.period_type = null;

    var t = this.tags.to.to.value
    var f = this.tags.from.from.value
    if(t.indexOf('/') != -1 || f.indexOf('/') != -1) {
      t = t.replace(/\//g, "-")
      f = f.replace(/\//g, "-")
    }
    updatePeriod(this, f, t)
    return false
  }

  //選択して期間を変更
  function setPeriod(self, day, type) {
    self.period = day;
    self.period_type = type;

    var b, f, t//基準、日付A、日付B
    if(type == 'years') {
      // b = moment()//日換算
      b = moment().startOf('year').add(1, 'years')//月換算の場合
      f = moment(b).subtract(day, type)
      t = moment(b).subtract(1, 'days')
    } else if(type == 'months') {
      // b = moment()//日換算
      b = moment().startOf('month').add(1, 'months')//月換算の場合
      f = moment(b).subtract(day, type)
      t = moment(b).subtract(1, 'days')
    } else if(type == 'weeks') {
      // b = moment()//日換算
      b = moment().startOf(type)//週換算の場合
      f = moment(b).subtract(day, type)
      t = moment(b).subtract(1, 'days')
    }
    updatePeriod(self, f.format('YYYY-MM-DD'), t.format('YYYY-MM-DD'))
  }

  //具体的に指定して期間を変更
  function updatePeriod(self, f, t) {
    self.from = moment(f)
    self.to = moment(t)
    self.display = getDisplay(f, t)
    self.update()
    self.setMinMax(self)

    self.parent.from = f
    self.parent.to = t
    self.parent.update()
  }
  setMinMax(self) {
    var input_from = self.tags.from.root.querySelector('input')
    var input_to = self.tags.to.root.querySelector('input')
    var f = input_from.value.replace(/\//g, "-")
    var t = input_to.value.replace(/\//g, "-")

    input_from.min = moment(f).subtract(5, 'years').startOf('year').format('YYYY-MM-DD')
    input_from.max = moment(t).format('YYYY-MM-DD')
    input_to.min = moment(f).format('YYYY-MM-DD')
    input_to.max = moment(t).endOf('year').add(1, 'days').format('YYYY-MM-DD')
  }

  function getDisplay(f, t) {
    return moment(f).format('YYYY/MM/DD') + ' 〜 ' + moment(t).format('YYYY/MM/DD');
  }

  $(document).on('click', '.dropdown-menu', function(e) {
    e.stopPropagation()
  });
  </script>
</riot-period-select>

<riot-period>
  <div data-riot-period>
    <riot-period-select from={ from } to={ to }></riot-period-select>
  </div>

  <script>
  this.from = ''
  this.to = ''

  this.on('update', function() {
    console.log('update: ', this.from, this.to)
  })
  </script>
</riot-period>
