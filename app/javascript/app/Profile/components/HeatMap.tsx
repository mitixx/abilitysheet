import * as CalHeatMap from 'cal-heatmap';
import * as moment from 'moment-timezone';
import * as React from 'react';
import { connect } from 'react-redux';
import { RootState } from '../../../lib/ducks';
import User from '../../../lib/models/User';

function mapStateToProps(state: RootState) {
  return {
    mobile: state.$$meta.env.mobileView(),
  };
}
interface IProps {
  user: User;
  viewport: boolean;
}
interface IState {
  items: any;
  date: any;
}
type Props = IProps & ReturnType<typeof mapStateToProps>;
class HeatMap extends React.PureComponent<Props, IState> {
  public state = {
    items: undefined,
    date: undefined,
  };

  public componentDidMount() {
    // @ts-ignore
    const cal = new CalHeatMap();
    const startDate = new Date();
    const range = this.props.mobile ? 3 : 12;
    startDate.setMonth(startDate.getMonth() - (range - 1));
    cal.init({
      domain: 'month',
      subDomain: 'day',
      data: `/api/v1/logs/cal-heatmap/${this.props.user.iidxid}?start={{d:start}}&stop={{d:end}}`,
      start: startDate,
      range,
      tooltip: true,
      cellSize: 9,
      domainLabelFormat: '%Y-%m',
      afterLoadData (timestamps: { [s: string]: number }) {
        const offset = (moment().tz('Asia/Tokyo').utcOffset() - moment().utcOffset())  * 60;
        const results: any = {};
        Object.keys(timestamps).forEach(timestamp => {
          const commitCount = timestamps[timestamp];
          results[parseInt(timestamp, 10) + offset] = commitCount;
        });
        return results;
      },
      onClick: (date: any, nb: any) => {
        this.setState({
          items: nb,
          date: `${date}`
        });
      }
    });
  }

  public renderDetail() {
    const { items, date } = this.state;
    if (items === undefined || date === undefined) { return null; }
    const targetDate = new Date(date);
    const text = `${targetDate.getFullYear()}-${('00' + (targetDate.getMonth() + 1)).substr(-2)}-${('00' + targetDate.getDate()).substr(-2)}`;
    return (
      <div className="center">
        <i className="fa fa-refresh" />
        <a href={(window as any).logs_path(this.props.user.iidxid, text)}>{text}</a>の更新数は{this.state.items}個です
      </div>
    );
  }

  public render() {
    return (
      <div className="uk-panel uk-panel-box">
        <h3 className="uk-panel-title">更新履歴</h3>
        <div id="cal-heatmap" />
        {this.renderDetail()}
      </div>
    );
  }
}

export default connect(mapStateToProps)(HeatMap);
