class ResponsiveAdsense extends React.Component {
  shouldComponentUpdate(nextProps, nextState) { return CheckComponentUpdate(this.props, nextProps, this.state, nextState) }

  render() {
    return (
      <div className='google-adsense'>
        <p className='center'>sponsored links</p>
        <GoogleAdsenseIns
          client={this.props.client}
          slot={this.props.slot}
          className='center'
          style={{display: 'block'}}
          format='auto'
        />
      </div>
    )
  }
}

ResponsiveAdsense.propTypes = {
  client: React.PropTypes.string.isRequired,
  slot: React.PropTypes.string.isRequired
}